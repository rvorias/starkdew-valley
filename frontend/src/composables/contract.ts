import { Contract } from 'starknet'
import abi from '../../../artifacts/abis/StarkVile.json'
import { getSessionSigner } from './session_signer'

const CONTRACT = '0x06271ee258cc25b76d3928204dd830551d005f2d837ce1be73974945d36b4a68'

export const starkvile = new Contract(abi, CONTRACT, getSessionSigner())
starkvile.estimate = async () => {
    console.log("my code");
    return {
    amount: 0,
    unit: "wei"
}};

