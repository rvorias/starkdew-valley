%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.cairo.common.signature import verify_ecdsa_signature
from starkware.cairo.common.registers import get_fp_and_pc
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.memcpy import memcpy
from starkware.cairo.common.math import assert_not_zero, assert_le, assert_nn, assert_le_felt
from starkware.starknet.common.syscalls import (
    call_contract, get_tx_info, get_contract_address, get_caller_address, get_block_timestamp
)
from starkware.cairo.common.hash_state import (
    hash_init, hash_finalize, hash_update, hash_update_single
)

from contracts.CallLogic import (Call, CallArray, from_call_array_to_call)

####

struct KeyConf:
    member public_key: felt
    member time: felt
    member timestamp_start: felt
    member contract: felt
    member total_value: felt
    member acc_value: felt
end


@storage_var
func _public_session_key(wallet_address: felt) -> (data: KeyConf):
end

#### 
@event
func setting_session_key(public_key: felt):
end

@external
func set_session_key{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        ecdsa_ptr: SignatureBuiltin*,
        range_check_ptr
    } (
        session_key: felt,
        time: felt
    ) -> ():

    assert_le(time, 3600*24)

    let (caller_address) = get_caller_address()
    let (tst) = get_block_timestamp()
    tempvar session_data: KeyConf = KeyConf(public_key = session_key, time=time, timestamp_start=tst, contract=0, total_value=0, acc_value=0)
    _public_session_key.write(caller_address, session_data)
    
    setting_session_key.emit(public_key=session_key)

    return ()
end


@view
func get_session_key{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        ecdsa_ptr: SignatureBuiltin*,
        range_check_ptr
    } (address: felt) -> (data: KeyConf):
    let (result) = _public_session_key.read(address)
    return (result)
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


    let (caller_address) = get_caller_address()

    let (local data: KeyConf) = _public_session_key.read(caller_address)
    
    if data.public_key == 0:
        return()
    end

    check_calls_rec(caller_address, calls_len, calls)
    
    let (tx_info) = get_tx_info()
    validate_session_key_signature(caller_address, tx_info.transaction_hash, tx_info.signature, tx_info.signature_len)

    return ()
end

@view
func check_authentication{
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

    let (caller_address) = get_caller_address()

    check_calls_rec(caller_address, calls_len, calls)

    return ()
end

func check_calls_rec{
        syscall_ptr: felt*, 
        pedersen_ptr: HashBuiltin*,
        ecdsa_ptr: SignatureBuiltin*,
        range_check_ptr
    } (
        caller: felt,
        index: felt,
        calls: Call*
    ) -> ():
    if index == 0:
        return()
    end

    check_call(caller, calls)

    return check_calls_rec(caller, index - 1, calls + Call.SIZE)
end

func check_call{
        syscall_ptr: felt*, 
        pedersen_ptr: HashBuiltin*,
        ecdsa_ptr: SignatureBuiltin*,
        range_check_ptr
    } (
        caller: felt,
        call_data: Call*
    ) -> ():
    alloc_locals

    let (local data: KeyConf) = _public_session_key.read(caller)
    if data.time != 0:
        let (tst) = get_block_timestamp()
        with_attr error_message("Time is too late. Got time={tst), need t={data.timestamp_start + data.time}"):
            assert_le_felt(tst, data.timestamp_start + data.time)
        end
    else:
        return()
    end

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
            public_key=session_key.public_key,
            signature_r=signatures[0],
            signature_s=signatures[1])
    return ()
end
