use nestnet::interfaces::INestnet::{INestnetDispatcher, INestnetDispatcherTrait};
use nestnet::nestnet::Nestnet;
use nestnet::types::ProjectProposal;
use snforge_std::{
    ContractClassTrait, DeclareResultTrait, EventSpyAssertionsTrait, declare, spy_events,
    start_cheat_caller_address, stop_cheat_caller_address,
};
use starknet::{ContractAddress, contract_address_const};

fn setup() -> (ContractAddress, ContractAddress, INestnetDispatcher) {
    let owner = contract_address_const::<'owner'>();
    let contract_class = declare("Nestnet").unwrap().contract_class();
    let (contract_address, _) = contract_class.deploy(@array![owner.into()]).unwrap();

    let dispatcher = INestnetDispatcher { contract_address: contract_address };

    (owner, contract_address, dispatcher)
}

#[test]
fn test_deployment_proposal() {
    let (owner, contract_address, dispatcher) = setup();
    let proposer = contract_address_const::<'proposer'>();

    let proposal = dispatcher.get_proposal(proposer, 43);
    assert(proposal.budget == 0, 'deployment failed');
    assert(proposal.amount_avaiable == 0, 'deployment failed');
    assert(proposal.percentage_left == 0, 'deployment failed');
    assert(proposal.percentage_used == 0, 'deployment failed');
    assert(proposal.contract_signature == 0, 'deployment failed');
}

#[test]
fn test_deployment_user() {
    let (owner, contract_address, dispatcher) = setup();
    let user = contract_address_const::<'proposer'>();

    let user = dispatcher.get_user(user);
    assert(!user.isAuthenticated, 'Deployment failed very well');
}

#[test]
fn create_proposal() {
    let (owner, contract_address, dispatcher) = setup();
    let user = contract_address_const::<'user'>();

    let name = 'Michael';
    let description = 'sapa riya';
    let budget = 200;
    let amount_avaiable = 40;
    let percentage_left = 20;
    let percentage_used = 80;
    let contract_signature = 'chainvfj';
    let Location = 'Kano';
    let Type = 'omo';
    let size = 9;
    let Estimated_value = 20;

    start_cheat_caller_address(dispatcher.contract_address, owner);
    let authentication_status = dispatcher.authenticate_user(user);
    stop_cheat_caller_address(dispatcher.contract_address);

    start_cheat_caller_address(dispatcher.contract_address, user);
    let proposal_id = dispatcher
        .owner_proposal(
            name,
            description,
            budget,
            amount_avaiable,
            percentage_left,
            percentage_used,
            contract_signature,
            Location,
            Type,
            size,
            Estimated_value,
        );

    let proposal = dispatcher.get_proposal(user, proposal_id);

    assert(proposal.name == 'Michael', 'An error occurred');
    assert(proposal.description == 'sapa riya', 'An error occurred');
    assert(proposal.budget == 200, 'An error occurred');
    assert(proposal.amount_avaiable == 40, 'An error occurred');
    assert(proposal.Type == 'omo', 'An error occurred');
}
#[test]
#[should_panic(expected: 'user is already authenticated')]
fn authenticate_user_twice() {
    let (owner, contract_address, dispatcher) = setup();
    let user = contract_address_const::<'user'>();

    let name = 'Michael';
    let description = 'sapa riya';
    let budget = 200;
    let amount_avaiable = 40;
    let percentage_left = 20;
    let percentage_used = 80;
    let contract_signature = 'chainvfj';
    let Location = 'Kano';
    let Type = 'omo';
    let size = 9;
    let Estimated_value = 20;

    start_cheat_caller_address(dispatcher.contract_address, owner);
    dispatcher.authenticate_user(user);
    dispatcher.authenticate_user(user);
    stop_cheat_caller_address(dispatcher.contract_address);

    start_cheat_caller_address(dispatcher.contract_address, user);
    let proposal_id = dispatcher
        .owner_proposal(
            name,
            description,
            budget,
            amount_avaiable,
            percentage_left,
            percentage_used,
            contract_signature,
            Location,
            Type,
            size,
            Estimated_value,
        );

    let proposal = dispatcher.get_proposal(user, proposal_id);

    assert(proposal.name == 'Michael', 'An error occurred');
    assert(proposal.description == 'sapa riya', 'An error occurred');
    assert(proposal.budget == 200, 'An error occurred');
    assert(proposal.amount_avaiable == 40, 'An error occurred');
    assert(proposal.Type == 'omo', 'An error occurred');
}

#[test]
#[should_panic(expected: 'User is not authenticated')]
fn create_proposal_by_unauthenticated_user() {
    let (owner, contract_address, dispatcher) = setup();
    let user = contract_address_const::<'user'>();

    let name = 'Michael';
    let description = 'sapa riya';
    let budget = 200;
    let amount_avaiable = 40;
    let percentage_left = 20;
    let percentage_used = 80;
    let contract_signature = 'chainvfj';
    let Location = 'Kano';
    let Type = 'omo';
    let size = 9;
    let Estimated_value = 20;

    start_cheat_caller_address(dispatcher.contract_address, user);
    let proposal_id = dispatcher
        .owner_proposal(
            name,
            description,
            budget,
            amount_avaiable,
            percentage_left,
            percentage_used,
            contract_signature,
            Location,
            Type,
            size,
            Estimated_value,
        );
}

#[test]
#[should_panic(expected: 'Name cannot be empty')]
fn create_proposal_by_empty_name() {
    let (owner, contract_address, dispatcher) = setup();
    let user = contract_address_const::<'user'>();

    let name = '';
    let description = 'sapa riya';
    let budget = 200;
    let amount_avaiable = 40;
    let percentage_left = 20;
    let percentage_used = 80;
    let contract_signature = 'chainvfj';
    let Location = 'Kano';
    let Type = 'omo';
    let size = 9;
    let Estimated_value = 20;

    start_cheat_caller_address(dispatcher.contract_address, user);
    let proposal_id = dispatcher
        .owner_proposal(
            name,
            description,
            budget,
            amount_avaiable,
            percentage_left,
            percentage_used,
            contract_signature,
            Location,
            Type,
            size,
            Estimated_value,
        );
}
#[test]
#[should_panic(expected: 'description cannot be empty')]
fn create_proposal_empty_description() {
    let (owner, contract_address, dispatcher) = setup();
    let user = contract_address_const::<'user'>();

    let name = 'Michael';
    let description = '';
    let budget = 200;
    let amount_avaiable = 40;
    let percentage_left = 20;
    let percentage_used = 80;
    let contract_signature = 'chainvfj';
    let Location = 'Kano';
    let Type = 'omo';
    let size = 9;
    let Estimated_value = 20;

    start_cheat_caller_address(dispatcher.contract_address, user);
    dispatcher
        .owner_proposal(
            name,
            description,
            budget,
            amount_avaiable,
            percentage_left,
            percentage_used,
            contract_signature,
            Location,
            Type,
            size,
            Estimated_value,
        );
}
#[test]
#[should_panic(expected: 'signature cannot be empty')]
fn create_proposal_zero_signature() {
    let (owner, contract_address, dispatcher) = setup();
    let user = contract_address_const::<'user'>();

    let name = 'Michael';
    let description = 'sapa riya';
    let budget = 200;
    let amount_avaiable = 40;
    let percentage_left = 20;
    let percentage_used = 80;
    let contract_signature = '';
    let Location = 'Kano';
    let Type = 'omo';
    let size = 9;
    let Estimated_value = 20;

    start_cheat_caller_address(dispatcher.contract_address, user);
    let proposal_id = dispatcher
        .owner_proposal(
            name,
            description,
            budget,
            amount_avaiable,
            percentage_left,
            percentage_used,
            contract_signature,
            Location,
            Type,
            size,
            Estimated_value,
        );
}
#[test]
#[should_panic(expected: 'Invalid budget')]
fn create_proposal_invalid_budget() {
    let (owner, contract_address, dispatcher) = setup();
    let user = contract_address_const::<'user'>();

    let name = 'Michael';
    let description = 'sapa riya';
    let budget = 0;
    let amount_avaiable = 40;
    let percentage_left = 20;
    let percentage_used = 80;
    let contract_signature = 'chainvfj';
    let Location = 'Kano';
    let Type = 'omo';
    let size = 9;
    let Estimated_value = 20;

    start_cheat_caller_address(dispatcher.contract_address, user);
    dispatcher
        .owner_proposal(
            name,
            description,
            budget,
            amount_avaiable,
            percentage_left,
            percentage_used,
            contract_signature,
            Location,
            Type,
            size,
            Estimated_value,
        );
}
#[test]
#[should_panic(expected: 'amount_avaiable cannot be zero')]
fn create_proposal_amount_available() {
    let (owner, contract_address, dispatcher) = setup();
    let user = contract_address_const::<'user'>();

    let name = 'Michael';
    let description = 'sapa riya';
    let budget = 200;
    let amount_avaiable = 0;
    let percentage_left = 20;
    let percentage_used = 80;
    let contract_signature = 'chainvfj';
    let Location = 'Kano';
    let Type = 'omo';
    let size = 9;
    let Estimated_value = 20;

    start_cheat_caller_address(dispatcher.contract_address, user);
    let proposal_id = dispatcher
        .owner_proposal(
            name,
            description,
            budget,
            amount_avaiable,
            percentage_left,
            percentage_used,
            contract_signature,
            Location,
            Type,
            size,
            Estimated_value,
        );
}
#[test]
#[should_panic(expected: 'percentage_left cannot be zero')]
fn create_proposal_percentage_left() {
    let (owner, contract_address, dispatcher) = setup();
    let user = contract_address_const::<'user'>();

    let name = 'Michael';
    let description = 'sapa riya';
    let budget = 200;
    let amount_avaiable = 40;
    let percentage_left = 0;
    let percentage_used = 80;
    let contract_signature = 'chainvfj';
    let Location = 'Kano';
    let Type = 'omo';
    let size = 9;
    let Estimated_value = 20;

    start_cheat_caller_address(dispatcher.contract_address, user);
    let proposal_id = dispatcher
        .owner_proposal(
            name,
            description,
            budget,
            amount_avaiable,
            percentage_left,
            percentage_used,
            contract_signature,
            Location,
            Type,
            size,
            Estimated_value,
        );
}
#[test]
#[should_panic(expected: 'User is not authenticated')]
fn create_proposal_percentage_used() {
    let (owner, contract_address, dispatcher) = setup();
    let user = contract_address_const::<'user'>();

    let name = 'Michael';
    let description = 'sapa riya';
    let budget = 200;
    let amount_avaiable = 40;
    let percentage_left = 20;
    let percentage_used = 10;
    let contract_signature = 'chainvfj';
    let Location = 'Kano';
    let Type = 'omo';
    let size = 9;
    let Estimated_value = 20;

    start_cheat_caller_address(dispatcher.contract_address, user);
    let proposal_id = dispatcher
        .owner_proposal(
            name,
            description,
            budget,
            amount_avaiable,
            percentage_left,
            percentage_used,
            contract_signature,
            Location,
            Type,
            size,
            Estimated_value,
        );
}

#[test]
#[should_panic(expected: 'Location cannot be empty')]
fn create_proposal_empty_location() {
    let (owner, contract_address, dispatcher) = setup();
    let user = contract_address_const::<'user'>();

    let name = 'Michael';
    let description = 'sapa riya';
    let budget = 200;
    let amount_avaiable = 40;
    let percentage_left = 20;
    let percentage_used = 10;
    let contract_signature = 'chainvfj';
    let Location = '';
    let Type = 'omo';
    let size = 9;
    let Estimated_value = 20;

    start_cheat_caller_address(dispatcher.contract_address, user);
    dispatcher
        .owner_proposal(
            name,
            description,
            budget,
            amount_avaiable,
            percentage_left,
            percentage_used,
            contract_signature,
            Location,
            Type,
            size,
            Estimated_value,
        );
}
#[test]
#[should_panic(expected: 'Type cannot be empty')]
fn create_proposal_empty_type() {
    let (owner, contract_address, dispatcher) = setup();
    let user = contract_address_const::<'user'>();

    let name = 'Michael';
    let description = 'sapa riya';
    let budget = 200;
    let amount_avaiable = 40;
    let percentage_left = 20;
    let percentage_used = 10;
    let contract_signature = 'chainvfj';
    let Location = 'Kano';
    let Type = '';
    let size = 9;
    let Estimated_value = 20;

    start_cheat_caller_address(dispatcher.contract_address, user);
    dispatcher
        .owner_proposal(
            name,
            description,
            budget,
            amount_avaiable,
            percentage_left,
            percentage_used,
            contract_signature,
            Location,
            Type,
            size,
            Estimated_value,
        );
}
#[test]
#[should_panic(expected: 'size cannot be zero')]
fn create_proposal_zero_size() {
    let (owner, contract_address, dispatcher) = setup();
    let user = contract_address_const::<'user'>();

    let name = 'Michael';
    let description = 'sapa riya';
    let budget = 200;
    let amount_avaiable = 40;
    let percentage_left = 20;
    let percentage_used = 70;
    let contract_signature = 'chainvfj';
    let Location = 'Kano';
    let Type = 'omo';
    let size = 0;
    let Estimated_value = 20;

    start_cheat_caller_address(dispatcher.contract_address, user);
    dispatcher
        .owner_proposal(
            name,
            description,
            budget,
            amount_avaiable,
            percentage_left,
            percentage_used,
            contract_signature,
            Location,
            Type,
            size,
            Estimated_value,
        );
}
#[test]
#[should_panic(expected: 'Estimated_value cannot be zero')]
fn create_proposal_zero_estimated_value() {
    let (owner, contract_address, dispatcher) = setup();
    let user = contract_address_const::<'user'>();

    let name = 'Michael';
    let description = 'sapa riya';
    let budget = 200;
    let amount_avaiable = 40;
    let percentage_left = 20;
    let percentage_used = 40;
    let contract_signature = 'chainvfj';
    let Location = 'Kano';
    let Type = 'omo';
    let size = 9;
    let Estimated_value = 0;

    start_cheat_caller_address(dispatcher.contract_address, user);
    dispatcher
        .owner_proposal(
            name,
            description,
            budget,
            amount_avaiable,
            percentage_left,
            percentage_used,
            contract_signature,
            Location,
            Type,
            size,
            Estimated_value,
        );
}

#[test]
fn create_proposal_event() {
    let (owner, contract_address, dispatcher) = setup();
    let user = contract_address_const::<'user'>();

    let name = 'Michael';
    let description = 'sapa riya';
    let budget = 200;
    let amount_avaiable = 40;
    let percentage_left = 20;
    let percentage_used = 80;
    let contract_signature = 'chainvfj';
    let Location = 'Kano';
    let Type = 'omo';
    let size = 9;
    let Estimated_value = 20;

    let mut spy = spy_events();

    start_cheat_caller_address(dispatcher.contract_address, owner);
    let authentication_status = dispatcher.authenticate_user(user);
    stop_cheat_caller_address(dispatcher.contract_address);

    start_cheat_caller_address(dispatcher.contract_address, user);
    let proposal_id = dispatcher
        .owner_proposal(
            name,
            description,
            budget,
            amount_avaiable,
            percentage_left,
            percentage_used,
            contract_signature,
            Location,
            Type,
            size,
            Estimated_value,
        );


    // Assert that the event was emitted with correct data
    spy
        .assert_emitted(
            @array![
                (
                    dispatcher.contract_address,
                    Nestnet::Event::ProjectProposal(
                        ProjectProposal {
                            name: name,
                            description: description,
                            budget: budget,
                            amount_avaiable: amount_avaiable,
                            percentage_left: percentage_left,
                            percentage_used: percentage_used,
                            contract_signature: contract_signature,
                            Location: Location,
                            Type: Type,
                            size: size,
                            Estimated_value: Estimated_value,
                        },
                    ),
                ),
            ],
        );
}
