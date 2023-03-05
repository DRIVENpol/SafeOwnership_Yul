// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract SafeOwnership {

    // The address of the future owner
    address private pendingOwner;

    // The current owner that will be the msg.sender
    address private currentOwner;

    // Events
    event NewOwnerProposed(address indexed newOwner);
    event OwnerChanged(address indexed newOwner);

    constructor() {
       address _v = msg.sender;

        assembly {
             let _s := currentOwner.slot
            sstore(_s, _v)
        }
    }

    modifier isOwner() {
        if(!_check(msg.sender, currentOwner)) revert();
        _;
    }

    // Set a pending owner
    function transferOwnership(address newOwner) external isOwner {
        bool _a =  _check(currentOwner, newOwner);
        if(_a) revert();

        address _v = newOwner;

        assembly {
             let _s := pendingOwner.slot
            sstore(_s, _v)
        }

        emit NewOwnerProposed(newOwner);
    }

    // Claim he ownership of the smart contract
    function claimOwnership() external {
        bool _a = _check(msg.sender, pendingOwner);
        if(!_a) revert();
        address _v1 = msg.sender;
        address _v2;

        assembly {
             let _s1 := currentOwner.slot
             let _s2 := pendingOwner.slot
            sstore(_s1, _v1)
            sstore(_s2, _v2)
        }

        emit OwnerChanged(msg.sender);
    }

    // Check if the caller is the current owner
    function _check(address _caller, address _currentOwner) internal pure returns(bool _isOwner) {
        uint256 _bm_address = (1 << 160) - 1;
        assembly {
            _caller := and(_caller, _bm_address)
            _currentOwner := and(_currentOwner, _bm_address)
            _isOwner := eq(_caller, _currentOwner) 
        }
    }

    function getOwner() public view returns(address _a) {
        assembly {
            let _s := currentOwner.slot 
            _a := sload(_s)
        }
    }

    function getPendingOwner() public view returns(address _a) {
        assembly {
            let _s := pendingOwner.slot 
            _a := sload(_s)
        }
    }
}
