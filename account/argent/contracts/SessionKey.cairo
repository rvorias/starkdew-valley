%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.cairo.common.signature import verify_ecdsa_signature
from starkware.cairo.common.registers import get_fp_and_pc
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.memcpy import memcpy
from starkware.cairo.common.math import assert_not_zero, assert_le, assert_nn
from starkware.starknet.common.syscalls import (
    call_contract, get_tx_info, get_contract_address, get_caller_address, get_block_timestamp
)
from starkware.cairo.common.hash_state import (
    hash_init, hash_finalize, hash_update, hash_update_single
)

from contracts.CallLogic import (Call, CallArray, from_call_array_to_call)

@storage_var
func _public_session_key(wallet_address: felt) -> (key: felt):
end

@external
func set_session_key{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        ecdsa_ptr: SignatureBuiltin*,
        range_check_ptr
    } (
        session_key: felt
    ) -> ():
    let (caller_address) = get_caller_address()
    _public_session_key.write(caller_address, session_key)
    return ()
end

@external
func authenticate_maybe{
        syscall_ptr: felt*, 
        pedersen_ptr: HashBuiltin*,
        ecdsa_ptr: SignatureBuiltin*,
        range_check_ptr
    } (
        call_array_len: felt,
        call_array: CallArray*,
        calldata_len: felt,
        calldata: felt*,
        nonce: felt) -> ():
    alloc_locals

    ############### TMP #############################
    # parse inputs to an array of 'Call' struct
    let (calls : Call*) = alloc()
    from_call_array_to_call(call_array_len, call_array, calldata, calls)
    let calls_len = call_array_len
    #################################################

    return ()
end


func validate_session_key_signature{
        syscall_ptr: felt*, 
        pedersen_ptr: HashBuiltin*,
        ecdsa_ptr: SignatureBuiltin*,
        range_check_ptr
    } (
        caller: felt,
        message: felt, 
        signatures: felt*,
        signatures_len: felt
    ) -> ():
    assert_nn (signatures_len - 2)
    let (session_key) = _public_session_key.read(caller)
    verify_ecdsa_signature(
            message=message,
            public_key=session_key,
            signature_r=signatures[0],
            signature_s=signatures[1])
    return ()
end
