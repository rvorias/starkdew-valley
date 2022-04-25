// Need to be very explicit about imports to avoid the Ledger js library.
export { Account } from 'starknet/account/default';
export type { AccountInterface } from 'starknet/account/interface';
export { Contract } from 'starknet/contract/default';
export { Provider } from 'starknet/provider/default';
export { Signer } from 'starknet/signer/default';
export { toBN, toHex } from 'starknet/utils/number';
export { getSelectorFromName } from 'starknet/utils/hash';
export { computeHashOnElements } from 'starknet/utils/hash';

import { getStarknet } from 'get-starknet';

export { getStarknet } from 'get-starknet';

export type IStarknetWindowObject = typeof getStarknet;

