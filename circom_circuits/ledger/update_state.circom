//test
pragma circom 2.1.9;

include "../hash_bn/poseidon2_hash.circom";
include "../hash_bn/poseidon2_perm.circom";
include "../misc/constants.circom";
include "notes.circom";
include "../hash_bn/merkle.circom";


template update_state_with_one_note(merkle_depth){
    signal input merkle_root;
    signal input old_value;
    signal input old_pk;
    signal input new_value;
    signal input new_pk;
    signal input selectors[merkle_depth];
    signal input path[merkle_depth];

    //Get the old note ID
    component old_note_id = derive_note_id();
    old_note_id.op_id <== 0;
    old_note_id.output_number <== 0;
    old_note_id.value <== old_value;
    old_note_id.pk <== old_pk;

    // Check that the note is in the tree
            //First check selectors are indeed bits
    for(var i = 0; i < merkle_depth; i++){
        selectors[i] * (1 - selectors[i]) === 0;
    }
            //Then check the note id is in the tree
    component old_membership = proof_of_membership(merkle_depth);
    for(var i = 0; i < merkle_depth; i++){
        old_membership.nodes[i] <== path[i];
        old_membership.selector[i] <== selectors[i];
    }
    old_membership.root <== merkle_root;
    old_membership.leaf <== old_note_id.out;
    old_membership.out === 1;

    // Then update the root with the new note replacing the old one
            // First derive the new note ID
    component new_note_id = derive_note_id();
    new_note_id.op_id <== 0;
    new_note_id.output_number <== 0;
    new_note_id.value <== new_value;
    new_note_id.pk <== new_pk;
            // Then update the Merkle root
    component new_root = compute_merkle_root(merkle_depth);
    for(var i = 0; i< merkle_depth; i++) {
        new_root.nodes[i] <== path[i];
        new_root.selector[i] <== selectors[i];
    }
    new_root.leaf <== new_note_id.out;

    // Output
    signal output updated_root;
    updated_root <== new_root.root;
}

template update_state_with_several_notes(merkle_depth, batch_size){
    signal input previous_root;
    signal input previous_note_values[batch_size];
    signal input previous_note_pk[batch_size];
    signal input new_note_values[batch_size];
    signal input new_note_pk[batch_size];
    signal input merkle_paths[batch_size][merkle_depth];
    signal input merkle_selectors[batch_size][merkle_depth];

    signal output new_root;

    component update[batch_size];

    // Update with the first note
    update[0] = update_state_with_one_note(merkle_depth);
    update[0].merkle_root <== previous_root;
    update[0].old_value <== previous_note_values[0];
    update[0].old_pk <== previous_note_pk[0];
    update[0].new_value <== new_note_values[0];
    update[0].new_pk <== new_note_pk[0];
    for(var i = 0; i < merkle_depth; i++){
        update[0].selectors[i] <== merkle_selectors[0][i];
        update[0].path[i] <== merkle_paths[0][i];
    }

    // Update all the other notes
    for(var i = 1; i < batch_size; i++){
        update[i] = update_state_with_one_note(merkle_depth);
        update[i].merkle_root <== update[i-1].updated_root;
        update[i].old_value <== previous_note_values[i];
        update[i].old_pk <== previous_note_pk[i];
        update[i].new_value <== new_note_values[i];
        update[i].new_pk <== new_note_pk[i];
        for(var j = 0; j < merkle_depth; j++){
            update[i].selectors[j] <== merkle_selectors[i][j];
            update[i].path[j] <== merkle_paths[i][j];
        }
    }

    new_root <== update[batch_size -1].updated_root;
}

component main {public [previous_root,previous_note_values,new_note_values]}= update_state_with_several_notes(32,3);