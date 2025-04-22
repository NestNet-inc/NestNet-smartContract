use starknet::ContractAddress;


#[derive(Copy, Drop, Serde, starknet::Store)]
pub struct TokenInfo {
    pub address: ContractAddress,
    pub symbol: felt252,
    pub chain: felt252,
    pub balance: u256,
    pub price: u256,
}
