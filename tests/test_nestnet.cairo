use nestnet::interfaces::INestnet::{INestnetDispatcher, INestnetDispatcherTrait};
use nestnet::nestnet::Nestnet;
use nestnet::types::{MilestoneStatus, MilestoneStatusUpdated, ProjectProposal};
use snforge_std::{
    ContractClassTrait, DeclareResultTrait, EventSpyAssertionsTrait, declare, spy_events,
    start_cheat_caller_address, stop_cheat_caller_address,
};
use starknet::ContractAddress;

fn setup() -> (ContractAddress, ContractAddress, INestnetDispatcher) {
    let owner: ContractAddress = 'owner'.try_into().unwrap();
    let contract_class = declare("Nestnet").unwrap().contract_class();
    let (contract_address, _) = contract_class.deploy(@array![owner.into()]).unwrap();

    let dispatcher = INestnetDispatcher { contract_address: contract_address };

    (owner, contract_address, dispatcher)
}

#[test]
fn test_deployment_proposal() {
    let (owner, contract_address, dispatcher) = setup();
    let proposer: ContractAddress = 'proposer'.try_into().unwrap();

    let proposal = dispatcher.get_proposal(proposer, 43);
    assert(proposal.is_none(), 'deployment failed');
}

#[test]
fn test_deployment_user() {
    let (owner, contract_address, dispatcher) = setup();
    let user: ContractAddress = 'proposer'.try_into().unwrap();

    let user = dispatcher.get_user(user);
    assert(!user.isAuthenticated, 'Deployment failed very well');
}

#[test]
fn create_proposal() {
    let (owner, contract_address, dispatcher) = setup();
    let user: ContractAddress = 'user'.try_into().unwrap();

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
    assert(proposal.is_some(), 'An error occurred');

    let found_proposal = proposal.unwrap();

    assert(found_proposal.name == 'Michael', 'An error occurred');
    assert(found_proposal.description == 'sapa riya', 'An error occurred');
    assert(found_proposal.budget == 200, 'An error occurred');
    assert(found_proposal.amount_avaiable == 40, 'An error occurred');
    assert(found_proposal.Type == 'omo', 'An error occurred');
}
#[test]
#[should_panic(expected: 'user is already authenticated')]
fn authenticate_user_twice() {
    let (owner, contract_address, dispatcher) = setup();
    let user: ContractAddress = 'user'.try_into().unwrap();

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
    assert(proposal.is_some(), 'An error occurred');

    let found_proposal = proposal.unwrap();

    assert(found_proposal.name == 'Michael', 'An error occurred');
    assert(found_proposal.description == 'sapa riya', 'An error occurred');
    assert(found_proposal.budget == 200, 'An error occurred');
    assert(found_proposal.amount_avaiable == 40, 'An error occurred');
    assert(found_proposal.Type == 'omo', 'An error occurred');
}

#[test]
fn test_get_all_proposals_by_user() {
    let (owner, contract_address, dispatcher) = setup();
    let user: ContractAddress = 'user'.try_into().unwrap();

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
    stop_cheat_caller_address(dispatcher.contract_address);

    start_cheat_caller_address(dispatcher.contract_address, user);
    let proposal_id = dispatcher
        .owner_proposal(
            name.clone(),
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

    let name1 = 'Michael';
    let description1 = 'sapa riya';
    let budget1 = 200;
    let amount_avaiable1 = 40;
    let percentage_left1 = 20;
    let percentage_used1 = 80;
    let contract_signature1 = 'chainvfj';
    let Location1 = 'Kano';
    let Type1 = 'omo';
    let size1 = 9;
    let Estimated_value1 = 20;

    start_cheat_caller_address(dispatcher.contract_address, user);
    let proposal_id1 = dispatcher
        .owner_proposal(
            name1,
            description1,
            budget1,
            amount_avaiable1,
            percentage_left1,
            percentage_used1,
            contract_signature1,
            Location1,
            Type1,
            size1,
            Estimated_value1,
        );

    let name2 = 'john';
    let description2 = 'sapa riya';
    let budget2 = 2000;
    let amount_avaiable2 = 900;
    let percentage_left2 = 20;
    let percentage_used2 = 80;
    let contract_signature2 = 'dgdgdg';
    let Location2 = 'Kaduna';
    let Type2 = 'omo0jkkkll';
    let size2 = 19;
    let Estimated_value2 = 200;

    start_cheat_caller_address(dispatcher.contract_address, user);
    let proposal_id2 = dispatcher
        .owner_proposal(
            name2,
            description2,
            budget2,
            amount_avaiable2,
            percentage_left2,
            percentage_used2,
            contract_signature2,
            Location2,
            Type2,
            size2,
            Estimated_value2,
        );

    let proposal = dispatcher.get_all_proposals_by_owner(user);
    assert(proposal.is_some(), 'An error occurred');

    let found_proposal = proposal.unwrap();
    // println!("The found proposal is {found_proposal}");

    assert(found_proposal.at(0).name == @name, 'An error occurred');
    assert(found_proposal.at(0).description == @description, 'An error occurred');
    assert(found_proposal.at(0).budget == @budget, 'An error occurred');
    assert(found_proposal.at(0).amount_avaiable == @amount_avaiable, 'An error occurred');
    assert(found_proposal.at(0).Type == @Type, 'An error occurred');

    assert(found_proposal.at(1).name == @name1, 'An error occurred');
    assert(found_proposal.at(1).description == @description1, 'An error occurred');
    assert(found_proposal.at(1).budget == @budget1, 'An error occurred');
    assert(found_proposal.at(1).amount_avaiable == @amount_avaiable1, 'An error occurred');
    assert(found_proposal.at(1).Type == @Type1, 'An error occurred');

    assert(found_proposal.at(2).name == @name2, 'An error occurred');
    assert(found_proposal.at(2).description == @description2, 'An error occurred');
    assert(found_proposal.at(2).budget == @budget2, 'An error occurred');
    assert(found_proposal.at(2).amount_avaiable == @amount_avaiable2, 'An error occurred');
    assert(found_proposal.at(2).Type == @Type2, 'An error occurred');
}

#[test]
#[should_panic(expected: 'User is not authenticated')]
fn create_proposal_by_unauthenticated_user() {
    let (owner, contract_address, dispatcher) = setup();
    let user: ContractAddress = 'user'.try_into().unwrap();

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
    let user: ContractAddress = 'user'.try_into().unwrap();

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
    let user = 'user'.try_into().unwrap();

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
    let user = 'user'.try_into().unwrap();

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
    let user = 'user'.try_into().unwrap();

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
    let user = 'user'.try_into().unwrap();

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
    let user = 'user'.try_into().unwrap();

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
    let user = 'user'.try_into().unwrap();

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
    let user = 'user'.try_into().unwrap();

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
    let user = 'user'.try_into().unwrap();

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
    let user = 'user'.try_into().unwrap();

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
    let user = 'user'.try_into().unwrap();

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
    let user = 'user'.try_into().unwrap();

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
                            owner: user,
                            proposal_id: proposal_id,
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

#[test]
fn test_update_milestone_status_success() {
    let (owner, contract_address, dispatcher) = setup();
    let user = 'user'.try_into().unwrap();

    // Authenticate user and create proposal
    start_cheat_caller_address(dispatcher.contract_address, owner);
    dispatcher.authenticate_user(user);
    stop_cheat_caller_address(dispatcher.contract_address);

    // Create milestone
    start_cheat_caller_address(dispatcher.contract_address, user);
    let milestone_id = dispatcher
        .create_milestone(1, 'Test Milestone', 'Description', 1000, 1234567890);

    // Update status to InProgress
    let success = dispatcher
        .update_milestone_status(milestone_id, MilestoneStatus::InProgress, 'progress_proof');

    assert(success, 'Status update failed');

    let milestone = dispatcher.milestone_checker(milestone_id).unwrap();
    assert(milestone.status == MilestoneStatus::InProgress, 'Status not updated');
}

#[test]
#[should_panic(expected: 'Invalid status transition')]
fn test_invalid_status_transition() {
    let (owner, contract_address, dispatcher) = setup();
    let user = 'user'.try_into().unwrap();

    start_cheat_caller_address(dispatcher.contract_address, owner);
    dispatcher.authenticate_user(user);
    stop_cheat_caller_address(dispatcher.contract_address);

    start_cheat_caller_address(dispatcher.contract_address, user);
    let milestone_id = dispatcher
        .create_milestone(1, 'Test Milestone', 'Description', 1000, 1234567890);

    // Try invalid transition: Pending -> Verified (should fail)
    dispatcher.update_milestone_status(milestone_id, MilestoneStatus::Verified, 'invalid_proof');
}

#[test]
#[should_panic(expected: 'Unauthorized caller')]
fn test_unauthorized_milestone_update() {
    let (owner, contract_address, dispatcher) = setup();
    let user = 'user'.try_into().unwrap();
    let unauthorized = 'unauthorized'.try_into().unwrap();

    start_cheat_caller_address(dispatcher.contract_address, owner);
    dispatcher.authenticate_user(user);
    stop_cheat_caller_address(dispatcher.contract_address);

    start_cheat_caller_address(dispatcher.contract_address, user);
    let milestone_id = dispatcher
        .create_milestone(1, 'Test Milestone', 'Description', 1000, 1234567890);
    stop_cheat_caller_address(dispatcher.contract_address);

    // Try to update from unauthorized account
    start_cheat_caller_address(dispatcher.contract_address, unauthorized);
    dispatcher.update_milestone_status(milestone_id, MilestoneStatus::InProgress, 'proof');
}

#[test]
fn test_milestone_status_event_emission() {
    let (owner, contract_address, dispatcher) = setup();
    let user = 'user'.try_into().unwrap();
    let mut spy = spy_events();

    start_cheat_caller_address(dispatcher.contract_address, owner);
    dispatcher.authenticate_user(user);
    stop_cheat_caller_address(dispatcher.contract_address);

    start_cheat_caller_address(dispatcher.contract_address, user);
    let milestone_id = dispatcher.create_milestone(1, 'Test', 'Desc', 1000, 1234567890);

    dispatcher.update_milestone_status(milestone_id, MilestoneStatus::InProgress, 'proof');

    spy
        .assert_emitted(
            @array![
                (
                    dispatcher.contract_address,
                    Nestnet::Event::MilestoneStatusUpdated(
                        MilestoneStatusUpdated {
                            milestone_id,
                            proposal_id: 1,
                            old_status: MilestoneStatus::Pending,
                            new_status: MilestoneStatus::InProgress,
                            updated_by: user,
                            timestamp: starknet::get_block_timestamp(),
                            proof_hash: 'proof',
                        },
                    ),
                ),
            ],
        );
}

#[test]
#[should_panic(expected: 'Invalid status transition')]
fn test_completion_without_target_amount() {
    let (owner, contract_address, dispatcher) = setup();
    let user = 'user'.try_into().unwrap();

    start_cheat_caller_address(dispatcher.contract_address, owner);
    dispatcher.authenticate_user(user);
    stop_cheat_caller_address(dispatcher.contract_address);

    start_cheat_caller_address(dispatcher.contract_address, user);
    let milestone_id = dispatcher.create_milestone(1, 'Test', 'Desc', 1000, 1234567890);

    // Try to complete without going through InProgress first (invalid transition: Pending ->
    // Completed)
    dispatcher.update_milestone_status(milestone_id, MilestoneStatus::Completed, 'proof');
}

#[test]
#[should_panic(expected: 'Target not reached')]
fn test_target_not_reached() {
    let (owner, contract_address, dispatcher) = setup();
    let user = 'user'.try_into().unwrap();

    start_cheat_caller_address(dispatcher.contract_address, owner);
    dispatcher.authenticate_user(user);
    stop_cheat_caller_address(dispatcher.contract_address);

    start_cheat_caller_address(dispatcher.contract_address, user);
    let milestone_id = dispatcher.create_milestone(1, 'Test', 'Desc', 1000, 1234567890);

    // First transition to InProgress (valid)
    dispatcher.update_milestone_status(milestone_id, MilestoneStatus::InProgress, 'start_proof');

    // Now try to complete without reaching target amount (current_amount = 0, target = 1000)
    dispatcher
        .update_milestone_status(milestone_id, MilestoneStatus::Completed, 'completion_proof');
}

#[test]
#[should_panic(expected: 'Milestone does not exist')]
fn test_update_nonexistent_milestone() {
    let (owner, contract_address, dispatcher) = setup();
    let user = 'user'.try_into().unwrap();

    start_cheat_caller_address(dispatcher.contract_address, owner);
    dispatcher.authenticate_user(user);
    stop_cheat_caller_address(dispatcher.contract_address);

    start_cheat_caller_address(dispatcher.contract_address, user);
    // Try to update a milestone that doesn't exist (ID 999)
    dispatcher.update_milestone_status(999, MilestoneStatus::InProgress, 'proof');
}
