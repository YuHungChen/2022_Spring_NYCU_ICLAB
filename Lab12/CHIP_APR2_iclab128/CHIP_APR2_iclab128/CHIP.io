######################################################
#                                                    #
#  Silicon Perspective, A Cadence Company            #
#  FirstEncounter IO Assignment                      #
#                                                    #
######################################################

Version: 2

#Example:  
#Pad: I_CLK 		W

#define your iopad location here


# North 
Pad: I_keyboard_0  N
Pad: I_keyboard_1  N
Pad: I_keyboard_2  N
Pad: I_keyboard_3  N
Pad: I_keyboard_4  N
Pad: VDDP2   N

Pad: VDDC0   N
Pad: I_VALID N
Pad: GNDC0   N

Pad: GNDP3   N
Pad: I_answer_0  N
Pad: I_answer_1  N
Pad: I_answer_2  N
Pad: I_answer_3  N
Pad: I_answer_4  N


# WEST


Pad: O_result_1  W
Pad: O_result_2  W
Pad: O_result_3  W
Pad: O_result_4  W
Pad: VDDP0       W
Pad: GNDP0       W

Pad: VDDC3    W
Pad: I_RESET  W
Pad: GNDC3    W

Pad: GNDP1    W
Pad: VDDP1    W
Pad: I_match_target_0   W
Pad: I_match_target_1   W
Pad: I_match_target_2   W
Pad: GNDP2    W


# EAST

Pad: O_out_value_7  E
Pad: O_out_value_8  E
Pad: O_out_value_9  E
Pad: O_out_value_10  E
Pad: GNDP4   E
Pad: VDDP4   E

Pad: VDDC1   E
Pad: I_CLK   E
Pad: GNDC1   E

Pad: pad_fill     E PFILL
Pad: I_weight_0   E
Pad: I_weight_1   E
Pad: I_weight_2   E
Pad: I_weight_3   E
Pad: VDDP3   E

# SOUTH

Pad: O_result_0  S
Pad: GNDP6       S
Pad: VDDP6       S
Pad: O_out_value_0  S
Pad: O_out_value_1  S
Pad: O_out_value_2  S

Pad: VDDC2    S
Pad: O_VALID  S
Pad: GNDC2    S

Pad: O_out_value_3  S
Pad: O_out_value_4  S
Pad: O_out_value_5  S
Pad: O_out_value_6  S
Pad: VDDP5   S
Pad: GNDP5   S


Pad: PCLR SE PCORNER
Pad: PCUL NW PCORNER
Pad: PCUR NE PCORNER
Pad: PCLL SW PCORNER