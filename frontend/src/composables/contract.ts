import { Contract } from 'starknet'
import abi from '../../../artifacts/abis/StarkVile.json'
import { getSessionSigner } from './session_signer'

const CONTRACT = '0x015c618ef96e0df85832cb1dd514c4fa4bb5b38ecabfe0464808bc8645fbc6f4'

export const starkvile = new Contract(abi, CONTRACT, getSessionSigner())
