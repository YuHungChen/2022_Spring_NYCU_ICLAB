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
Pad: I_IN_2  N
Pad: I_IN_3  N
Pad: GNDP0   N

Pad: VDDC0   N
Pad: I_VALID N
Pad: GNDC0   N

Pad: VDDP1   N
Pad: I_IN_4  N
Pad: I_IN_5  N


# WEST

Pad: O_OUT_1  W
Pad: O_OUT_0  W
Pad: GNDP3    W

Pad: VDDC3    W
Pad: I_RESET  W
Pad: GNDC3    W

Pad: VDDP0    W
Pad: I_IN_0   W
Pad: I_IN_1   W


# EAST


Pad: O_OUT_6  E
Pad: O_OUT_7  E
Pad: VDDP2   E

Pad: VDDC1   E
Pad: I_CLK   E
Pad: GNDC1   E

Pad: GNDP1   E
Pad: I_IN_7  E
Pad: I_IN_6  E


# SOUTH


Pad: O_OUT_2  S
Pad: O_OUT_3  S
Pad: VDDP3    S

Pad: VDDC2    S
Pad: O_VALID  S
Pad: GNDC2    S

Pad: GNDP2    S
Pad: O_OUT_4  S
Pad: O_OUT_5  S




Pad: PCLR SE PCORNER
Pad: PCUL NW PCORNER
Pad: PCUR NE PCORNER
Pad: PCLL SW PCORNER