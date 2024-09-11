// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.12 <0.9.0;

// Coin isimli bir sözleşme oluşturuluyor
contract Coin {
    // public anahtar kelimesi ile darphane değişkenine dışarıdan erişilebilir
    // darphane, yeni coin basabilecek olan adresi temsil eder
    address public minter;
    
    // mapping ile adreslerin coin bakiyeleri tutulur
    mapping(address => uint) public balances;

    // Olaylar (event'ler), dış dünyaya loglama yapmayı sağlar
    // Sent olayını tetiklediğimizde transfer gerçekleştiğini loglarız
    event Sent(address from, address to, uint amount);

    // Constructor: Sözleşme ilk kez deploy edildiğinde çalışır
    // Bu kısımda minter adresi, kontratı oluşturan kişiye atanır (msg.sender)
    constructor() {
        minter = msg.sender;  // Kontratı deploy eden adres
    }

    // Yeni coin basma fonksiyonu (mint)
    // Sadece minter (kontratı oluşturan kişi) coin basabilir
    function mint(address receiver, uint amount) public {
        require(msg.sender == minter, "Only minter can mint new coins");
        balances[receiver] += amount;  // Alıcıya yeni coin eklenir
    }

    // Hata mesajları: Eğer işlem başarılı olmazsa,
    // neden başarısız olduğunu anlamak için kullanılır
    error InsufficientBalance(uint requested, uint available);  // Hata türü tanımı

    // Mevcut coinleri bir adresten başka birine gönderme fonksiyonu (send)
    function send(address receiver, uint amount) public {
        // Göndericinin bakiyesinin yeterli olup olmadığını kontrol eder
        require(amount <= balances[msg.sender], "Insufficient balance");
        // Eğer bakiye yeterliyse, işlem gerçekleştirilir
        balances[msg.sender] -= amount;  // Gönderenin bakiyesinden düş
        balances[receiver] += amount;    // Alıcının bakiyesine ekle
        emit Sent(msg.sender, receiver, amount);  // Olayı logla
    }

}
