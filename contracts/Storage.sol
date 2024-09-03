// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

contract SimpleStorage{
    uint storedData;

    function setData(uint _data) public  {
	   storedData = _data; }

    function getData() public view returns  (uint) {
        return  storedData;
         }
    
   function deleteData() public {
        storedData = 0;
    }

}