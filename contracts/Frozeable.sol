// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Frozeable {
    bool private _frozen = false;

    // Bu modifier, kontratın dondurulmamış olduğunu kontrol eder. 
    // Eğer dondurulmuşsa, işlemi iptal eder.
    modifier notFrozen() {
        require(!_frozen, "Inactive Contract."); // Kontrat dondurulmuşsa, işlem yapılmaz.
        _;
    }

    // Bu fonksiyon kontratı dondurur, yani kontrat üzerinde daha fazla işlem yapılamaz.
    function freeze() internal {
        _frozen = true;
    }
}

contract SimplePaymentChannel is Frozeable {
    address payable public sender;    // Ödeme gönderen adres (kanalı başlatan kişi).
    address payable public recipient; // Ödemeyi alan adres (alıcı).
    uint256 public expiration;        // Zaman aşımı süresi (eğer alıcı kanalı kapatmazsa ödeme iptal olur).

    // Yapıcı fonksiyon: Kontratı başlatır. Gönderen adresi msg.sender olur ve 
    // alıcı adresi ve zaman aşımı süresi belirlenir.
    constructor (address payable recipientAddress, uint256 duration)
        payable
    {
        sender = payable(msg.sender); // Gönderen kişi kontratı oluşturan kişi olur.
        recipient = recipientAddress; // Alıcı, constructor'da belirtilen adres olur.
        expiration = block.timestamp + duration; // Zaman aşımı süresi, şu andaki zamanın üstüne eklenir.
    }

    // Alıcı herhangi bir zamanda gönderici tarafından imzalanmış bir miktarı sunarak kanalı kapatabilir.
    // Belirtilen miktar alıcıya gönderilir, geri kalan bakiyede göndericiye iade edilir.
    function close(uint256 amount, bytes memory signature)
        external
        notFrozen
    {
        require(msg.sender == recipient); // Bu fonksiyonu sadece alıcı çağırabilir.
        require(isValidSignature(amount, signature)); // Gönderilen imzanın geçerli olduğunu kontrol eder.

        recipient.transfer(amount); // Belirtilen miktar alıcıya gönderilir.
        freeze(); // Kontrat dondurulur.
        sender.transfer(address(this).balance); // Geri kalan bakiye göndericiye iade edilir.
    }

    // Gönderici kanalı kapatmadan zaman aşımını uzatabilir.
    function extend(uint256 newExpiration)
        external
        notFrozen
    {
        require(msg.sender == sender); // Bu fonksiyonu sadece gönderici çağırabilir.
        require(newExpiration > expiration); // Yeni zaman aşımı süresi, mevcut süreden büyük olmalıdır.

        expiration = newExpiration; // Yeni zaman aşımı süresi ayarlanır.
    }

    // Eğer zaman aşımı süresi dolmuşsa ve alıcı kanalı kapatmamışsa,
    // kalan Ether'ler göndericiye geri gönderilir.
    function claimTimeout()
        external
        notFrozen
    {
        require(block.timestamp >= expiration); // Zaman aşımının dolmuş olduğunu kontrol eder.
        freeze(); // Kontrat dondurulur.
        sender.transfer(address(this).balance); // Kalan bakiye göndericiye iade edilir.
    }

    // İmzanın geçerli olup olmadığını kontrol eden fonksiyon.
    function isValidSignature(uint256 amount, bytes memory signature)
        internal
        view
        returns (bool)
    {
        // Gönderilen miktar ve kontrat adresine göre mesaj oluşturulur.
        bytes32 message = prefixed(keccak256(abi.encodePacked(this, amount)));
        // İmzanın gönderici tarafından atıldığını kontrol eder.
        return recoverSigner(message, signature) == sender;
    }

    // Aşağıdaki tüm fonksiyonlar, "imza oluşturma ve doğrulama" bölümünden alınmıştır.

    // İmza verisini parçalayan fonksiyon: v, r, s bileşenlerine ayırır.
    function splitSignature(bytes memory sig)
        internal
        pure
        returns (uint8 v, bytes32 r, bytes32 s)
    {
        require(sig.length == 65); // İmza uzunluğu 65 byte olmalıdır.

        assembly {
            // İlk 32 byte, r değeri.
            r := mload(add(sig, 32))
            // İkinci 32 byte, s değeri.
            s := mload(add(sig, 64))
            // Son 1 byte, v değeri.
            v := byte(0, mload(add(sig, 96)))
        }
        return (v, r, s);
    }

    // İmza sahibini geri döndüren fonksiyon.
    function recoverSigner(bytes32 message, bytes memory sig)
        internal
        pure
        returns (address)
    {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig); // İmzayı parçalar.
        return ecrecover(message, v, r, s); // İmzanın hangi adres tarafından atıldığını bulur.
    }

    // eth_sign işlemi gibi davranan bir prefikslenmiş hash oluşturan fonksiyon.
    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}
