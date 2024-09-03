// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;

import {SimpleStorage} from "contracts/Storage.sol";

contract StorageFactory{

    SimpleStorage public simpleStorage;

    function createSimpleStorageContract()  public {    
        simpleStorage = new  SimpleStorage();    
        
    }
}