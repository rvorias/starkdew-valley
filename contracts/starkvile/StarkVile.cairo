# MIT License
%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.math import assert_nn_le, unsigned_div_rem, assert_not_zero, assert_not_equal
from starkware.cairo.common.math_cmp import is_nn_le, is_le
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
@view
func get_workers{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(address: felt) -> (workers : felt):
    alloc_locals
    let (workers) = players_workers.read(address)
    return (workers=workers)
end

# GET WORKERS
@view
func get_wheat{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(address: felt) -> (wheat : felt):
    alloc_locals
    let (wheat) = players_wheat.read(address)
    return (wheat=wheat)
end

func _allFarms{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    } (index: felt, farm_output: Farm*) -> (total_farms: Farm*):
    
    if index == 0:
        return (farm_output)
    end

    let (farm) = farms.read(index - 1)

    assert farm_output.plant_time = farm.plant_time
    assert farm_output.owner = farm.owner
    assert farm_output.x_coord = farm.x_coord
    assert farm_output.y_coord = farm.y_coord

    return _allFarms(index - 1, farm_output + Farm.SIZE)
end

@view
func getAllFarms{
        syscall_ptr: felt*,
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }() -> (farms_len: felt, farms: Farm*):
    alloc_locals
    let (local farms: Farm*) = alloc()
    let (total_farms) = farm_counter.read()
    let (all_farms) = _allFarms(total_farms, farms)
    return ((all_farms - farms) / Farm.SIZE, farms)
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

    # with_attr error_message("Ser, claim a peasant first"):
    #     assert_not_zero(workers)
    # end

    let (farm_number) = farm_counter.read()

    farms.write(farm_number, Farm(planting_time, 2, x_coord, y_coord))

    farm_counter.write(farm_number + 1)

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
        assert farm.owner = 2
        assert farm.x_coord = x_coord
        assert farm.y_coord = y_coord
    end

    let (available, remainder) = get_available_resources(farm_id)

    let claimable = available * CLAIM_AMOUNT

    let (less_than) = is_le(available, 5)

    if less_than == 1:
        let (current_balance) = players_wheat.read(caller)

        # return remainder
        farms.write(farm_id, Farm(block_timestamp - remainder, caller, x_coord, y_coord))

        players_wheat.write(caller, current_balance + claimable)
        return (1)
    end
    
    farms.write(farm_id, Farm(block_timestamp - remainder, caller, x_coord, y_coord))

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