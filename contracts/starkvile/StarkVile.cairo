# MIT License
%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.math import assert_nn_le, unsigned_div_rem, assert_not_zero, assert_not_equal
from starkware.cairo.common.math_cmp import is_nn_le
from starkware.cairo.common.hash_state import hash_init, hash_update, HashState
from starkware.cairo.common.alloc import alloc
from starkware.starknet.common.syscalls import (
    get_caller_address,
    get_block_timestamp,
    get_contract_address,
)
from starkware.cairo.common.uint256 import Uint256, uint256_eq

##########
# EVENTS #
##########


###############
# CONSTRUCTOR #
###############

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    return ()
end


# @external
# func initializer{
#         syscall_ptr : felt*,
#         pedersen_ptr : HashBuiltin*,
#         range_check_ptr
#     }(proxy_admin: felt):
#     Proxy_initializer(proxy_admin)
#     return ()
# end

# @external
# func upgrade{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
#     new_implementation : felt
# ):
#     Proxy_only_admin()
#     Proxy_set_implementation(new_implementation)
#     return ()
# end

# @view
# func get_implementation{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
#     address : felt
# ):
#     let (address) = Proxy_get_implementation()
#     return (address)
# end

# @view
# func get_admin{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (
#     admin : felt
# ):
#     let (admin) = Proxy_get_admin()
#     return (admin)
# end

############
# EXTERNAL #
############

const CLAIM_TIME = 30
const CLAIM_AMOUNT = 10

struct Farm:
    member plant_time: felt
    member owner: felt
    member x_coord: felt
    member y_coord: felt
end 

@storage_var
func players_workers(address : felt) -> (number_of_workers : felt):
end

@storage_var
func farms(idx : felt) -> (farm : Farm):
end

@storage_var
func farm_counter() -> (value : felt):
end

@storage_var
func players_wheat(address : felt) -> (value : felt):
end

# GET WORKERS
@external
func get_workers{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(address: felt) -> (workers : felt):
    alloc_locals
    let (workers) = players_workers.read(address)
    return (workers=workers)
end

# GET WORKERS
@external
func get_wheat{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(address: felt) -> (wheat : felt):
    alloc_locals
    let (wheat) = players_wheat.read(address)
    return (wheat=wheat)
end

# CLAIMS WORKER
@external
func claim_worker{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (success : felt):
    alloc_locals

    # TODO: Based off address, need better perm 
    let (caller) = get_caller_address()

    let (workers) = players_workers.read(caller)

    with_attr error_message("You have already claimed"):
        assert_not_equal(workers, 1)
    end

    # add worker
    players_workers.write(caller, 1)

    #TOOD: Emit 

    return (1)
end

@external
func build_farm{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(x_coord: felt, y_coord: felt
) -> (success : felt):
    alloc_locals

    let (caller) = get_caller_address()

    let (planting_time) = get_block_timestamp()

    let (workers) = players_workers.read(caller)

    with_attr error_message("Ser, claim a peasant first"):
        assert_not_zero(workers)
    end

    let (farm_number) = farm_counter.read()

    farms.write(farm_number, Farm(planting_time, caller, x_coord, y_coord))

    return (1)
end

@external
func claim_resources{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
farm_id: felt, x_coord: felt, y_coord: felt) -> (success : felt):
    alloc_locals

    let (block_timestamp) = get_block_timestamp()

    let (caller) = get_caller_address()

    let (farm: Farm) = farms.read(farm_id)

    # check owner
    with_attr error_message("Ser, you do not own this farm"):
        assert farm.owner = caller
        assert farm.x_coord = x_coord
        assert farm.y_coord = y_coord
    end

    let (available, remainder) = get_available_resources(farm_id)

    let claimable = available * CLAIM_AMOUNT

    let (current_balance) = players_wheat.read(caller)

    # return remainder
    farms.write(farm_id, Farm(block_timestamp - remainder, caller, x_coord, y_coord))

    players_wheat.write(caller, current_balance + claimable)

    return (1)
end


# FETCHES AVAILABLE RESOURCES PER CYCLE
@view
func get_available_resources{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    farm_id : felt
) -> (days_accrued : felt, remainder : felt):

    let (block_timestamp) = get_block_timestamp()

    let (farm : Farm) = farms.read(farm_id)

    let (days_accrued, seconds_left_over) = unsigned_div_rem(block_timestamp - farm.plant_time, CLAIM_TIME)

    return (days_accrued, seconds_left_over)
end