#[contract]
mod Voting_contract {
    // core library imports
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use array::ArrayTrait;
    use clone::Clone;
    use array::ArrayTCloneImpl;

    // Contract storage
    struct Storage {
        admin: ContractAddress,
        election_participants: LegacyMap::<u64, @Array<ContractAddress>>,
        no_of_winners: LegacyMap::<u64, u64>,
        election_no_is_used: LegacyMap::<u64, bool>,
        legitimate_candidate: LegacyMap::<(u64, ContractAddress), bool>,
        no_of_votes: LegacyMap::<(u64, ContractAddress), u128>
    }

    #[constructor]
    fn constructor() {
        admin::write(get_caller_address());
    }

    #[events]
    fn participas_registered(
        all_participans: Array::<ContractAddress>, no_of_winners: u64, election_no: u64
    ) {}

    #[events]
    fn vote_succesful(votter: ContractAddress, election_no: u256) {}

    #[external]
    fn Register_Participants(
        participants_: Array::<ContractAddress>, no_of_winners: u64, election_no: u64
    ) {
        let election_no_check: bool = election_no_is_used::read(election_no);
        assert(election_no_check == false, 'Election number already used');
        election_no_is_used::write(election_no, true);
        no_of_winners::write(election_no, no_of_winners);
        election_participants::write(election_no, @participants_);
        let no_of_candidates: usize = participants_.len();
        participas_registered(participants_, no_of_winners, election_no);
    }
    // #[external]
    // fn Vote(candidate: Array::<ContractAddress>) -> bool {}

    #[view]
    fn check_eligibility() {}


    // Internal Functions

    fn document_candidate(ref candidate: ContractAddress, ref election_no: u64) {
        legitimate_candidate::write((election_no, candidate), true);
    }
}
