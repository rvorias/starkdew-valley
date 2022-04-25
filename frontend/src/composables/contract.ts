import { Contract } from 'starknet'
import abi from '../../../artifacts/abis/StarkVile.json'
import { getSessionSigner } from './session_signer'

const CONTRACT = '0x0286d2294d624bad2a3c8dd5306468c37402ac7a799488cea40307c7fbde51d7'

export const starkvile = new Contract(abi, CONTRACT, getSessionSigner())
