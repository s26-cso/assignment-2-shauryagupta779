.text

.globl make_node
.type make_node, @function
make_node:
    addi sp, sp, -16
    sd ra, 8(sp)
    sd s0, 0(sp)
    
    mv s0, a0           # s0 = val
    li a0, 24
    call malloc
    
    beq a0, x0, .make_node_done
    
    sw s0, 0(a0)        # node->val = val
    sd x0, 8(a0)        # node->left = NULL
    sd x0, 16(a0)       # node->right = NULL
    
.make_node_done:
    ld s0, 0(sp)
    ld ra, 8(sp)
    addi sp, sp, 16
    ret

.globl insert
.type insert, @function
insert:
    addi sp, sp, -32
    sd ra, 24(sp)
    sd s0, 16(sp)
    sd s1, 8(sp)
    sd s2, 0(sp)
    
    mv s0, a0           # s0 = root
    mv s1, a1           # s1 = val
    
    beq s0, x0, .insert_create_new
    
    mv s2, s0           # s2 = current node
    
.insert_loop:
    lw a0, 0(s2)        # a0 = current->val
    blt s1, a0, .insert_go_left
    bgt s1, a0, .insert_go_right
    mv a0, s0           # duplicate, return root
    j .insert_done
    
.insert_go_left:
    ld a0, 8(s2)        # a0 = current->left
    bne a0, x0, .insert_descend_left
    
    mv a0, s1
    call make_node
    sd a0, 8(s2)        # current->left = new_node
    mv a0, s0
    j .insert_done
    
.insert_descend_left:
    mv s2, a0
    j .insert_loop
    
.insert_go_right:
    ld a0, 16(s2)       # a0 = current->right
    bne a0, x0, .insert_descend_right
    
    mv a0, s1
    call make_node
    sd a0, 16(s2)       # current->right = new_node
    mv a0, s0
    j .insert_done
    
.insert_descend_right:
    mv s2, a0
    j .insert_loop
    
.insert_create_new:
    mv a0, s1
    call make_node
    j .insert_done
    
.insert_done:
    ld s2, 0(sp)
    ld s1, 8(sp)
    ld s0, 16(sp)
    ld ra, 24(sp)
    addi sp, sp, 32
    ret

.globl get
.type get, @function
get:
    beq a0, x0, .get_done
    
    lw a2, 0(a0)        # a2 = current->val
    blt a1, a2, .get_left
    bgt a1, a2, .get_right
    ret
    
.get_left:
    ld a0, 8(a0)        # a0 = current->left
    j get
    
.get_right:
    ld a0, 16(a0)       # a0 = current->right
    j get
    
.get_done:
    ret

.globl getAtMost
.type getAtMost, @function
getAtMost:
    # a0 = val, a1 = root
    # return greatest value <= val, or -1
    li a2, -1           # a2 = result = -1
    
.get_at_most_loop:
    beq a1, x0, .get_at_most_done
    
    lw a3, 0(a1)        # a3 = current->val
    bgt a3, a0, .get_at_most_go_left
    
    mv a2, a3           # result = current->val
    ld a1, 16(a1)       # go right
    j .get_at_most_loop
    
.get_at_most_go_left:
    ld a1, 8(a1)        # go left
    j .get_at_most_loop
    
.get_at_most_done:
    mv a0, a2
    ret
