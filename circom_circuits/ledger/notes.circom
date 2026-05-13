//test
pragma circom 2.1.9;

include "../hash_bn/poseidon2_hash.circom";
include "../hash_bn/poseidon2_perm.circom";
include "../misc/constants.circom";

template derive_public_key(){
    signal input secret_key;
    signal output out;

    component hash = Compression();
    component dst = KDF();
    hash.inp[0] <== dst.out;
    hash.inp[1] <== secret_key;
    out <== hash.out;
}

template derive_note_id(){
    signal input op_id;
    signal input output_number;
    signal input value;
    signal input pk;

    component note_id = Poseidon2_hash(5);
    component note_id_v1 = NOTE_ID_V1();
    note_id.inp[0] <== note_id_v1.out;
    note_id.inp[1] <== op_id;
    note_id.inp[2] <== output_number;
    note_id.inp[3] <== value;
    note_id.inp[4] <== pk;

    signal output out;
    out <== note_id.out;
}