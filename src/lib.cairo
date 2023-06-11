#[contract]
mod Voting_contract {
    #[storage]
    struct storage {
        admin: contract_Address
    }

    #[constructor]
    fn constructor() {
        admin = contract_caller;
    }

    #[events]
    fn participas_registered(
        participans: ArrayTrait::<contract_Address>, no_of_winners: u256, election_no: u256
    ) {}

    fn vote_succesful(votter: contract_Address, election_no: u256) {}

    #[External]
    fn Register_Participants(
        Participants: ArrayTrait::<contract_Address>, no_of_winners: u256
    ) -> bool {}

    fn Vote(candidate: ArrayTrait::<contract_Address>) -> bool {}

    #[view]
    fn check_eligibility() {}
}
