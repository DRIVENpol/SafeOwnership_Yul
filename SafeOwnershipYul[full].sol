object "SafeOwnership" {

    // The constructor
    code {
        // We store the address of msg.sender
        // to slot 0
        sstore(0, caller())

        // We deploy the smart contract
        datacopy(0, dataoffset("runtime"), datasize("runtime"))
        return(0, datasize("runtime"))        
    }

    // The runtime code of our smart contract
    object "runtime" {
        code {
            // We don't allow eth transfers to the smart contract
            require(iszero(callvalue()))

            // **** Storage layout ****
            function init_owner() -> p { p := 0 }
            function pen_owner() -> p { p := 1 }

            // **** Storage access ****

            // Read functions
            function get_init_owner() -> o {
                o := sload(init_owner())
            }

            function get_pen_owner() -> o {
                o := sload(pen_owner())
            }

            // Write functions
            function propose_pen_owner(the_pen_owner) {
                sstore(get_pen_owner(), the_pen_owner)
            }

            function change_init_owner_reset() {
                sstore(get_init_owner(), sload(get_pen_owner()))
                sstore(get_pen_owner(), 0)
            }

            // **** Modifiers ****
            function called_by_init_owner() -> cbio {
                cbio := eq(get_init_owner(), caller())
            }

            function called_by_pen_owner() -> cbpo {
                cbpo := eq(get_pen_owner(), caller())
            }

            function require(condition) {
                if iszero(condition) { revert(0, 0) }
            }

            // **** Utility functions ****

                 // *** Decoding functions ***
                function selector() -> s {
                    s := div(calldataload(0), 0x100000000000000000000000000000000000000000000000000000000)
                }

                function decodeAsAddress(offset) -> v {
                    v := decodeAsUint(offset)
                    if iszero(iszero(and(v, not(0xffffffffffffffffffffffffffffffffffffffff)))) {
                        revert(0, 0)
                    }
                }

                function decodeAsUint(offset) -> v {
                    let pos := add(4, mul(offset, 0x20))
                    if lt(calldatasize(), add(pos, 0x20)) {
                        revert(0, 0)
                    }
                    v := calldataload(pos)
                }

                // *** Encoding functions ***
                function returnUint(v) {
                    mstore(0, v)
                    return(0, 0x20)
                }

                function returnTrue() {
                    returnUint(1)
                }

            // **** Main functions ****
            function proposeOwnership(newPendingOwner) {
                require(newPendingOwner)
                require(called_by_init_owner())
                propose_pen_owner(newPendingOwner)
            }

            function claimOwnership() {
                require(called_by_pen_owner())
                change_init_owner_reset()
            }

            // Dispatcher
            switch selector()

            // "proposeOwnership(address)"
            case 0x710bf322 {
                proposeOwnership(decodeAsAddress(0))
                returnTrue()
            }

            // "claimOwnership()"
            case 0x4e71e0c8 {
                claimOwnership()
                returnTrue()
            }

            default {
                revert(0, 0)
            }
        }
    }

}
