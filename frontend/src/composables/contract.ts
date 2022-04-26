import { Contract } from 'starknet'
import abi from '../../../backend/starkdew/artifacts/abis/StarkVile.json'
import { getSessionSigner } from './session_signer'

import { GAME_CONTRACT } from './contract_addresses';

export const starkvile = new Contract(abi, GAME_CONTRACT, getSessionSigner())
