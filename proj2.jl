using Printf
using LinearAlgebra
using DelimitedFiles

#-------------------------------------------------------------------- EXERCISE 2

V3 = [0; 0; 1] #vector of R3 we want to project in R2

function to_2d(V3)
    #we calculate de matrix (see the first exercise)

    a = 0.5*cos(42 * pi/180)
    b = 0.5*sin(42 * pi/180)
    c = cos(7 * pi/180)
    d = sin(7 * pi/180)
    e = 0
    f = 1

    M = [-a c e;
        -b -d f]
     #matrix found in the first exercise

    V2 = M*V3 #operation to transform V3 of R3 in V2 in R2

    print("The vector ", V3, " representated in R2 is: ", V2)
    println()
end

to_2d(V3)

print("--------------------------------------\n")

#-------------------------------------------------------------------- EXERCISE 3
V = [1;1;1] #vector to be rotated
phi = 90 #degrees
z = [0;0;1] #axis z

function rotate_phi_z(phi, z, V)
    #formula de Rodriges to find "R", the rotation matrix
    Z = [0 -z[3,1] z[2,1];
         z[3,1] 0 -z[1,1];
        -z[2,1] z[1,1] 0]

    #R=[0 -1 0; 1 0 0; 0 0 1]

    R = I + Z*sin(phi*pi/180) + Z^2*(1-cos(phi*pi/180))
    #just above, we multiply pi/180 to the angle (in degrees) to obtain the angle in radians
    #so julia can do the operation we want

    #next, we will check if R is a rotation matrix: R*R'=I and det(R)=1
    if (R*R'==I && det(R)==1)
        #we find the rotated matrix:
        U = R*V
        print("V rotated is = ", U)
    else
        print("R = ", R, " is NOT a rotation matrix\n")

    end
end

rotate_phi_z(phi, z, V)
