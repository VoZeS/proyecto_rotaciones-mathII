using Printf
using LinearAlgebra
using DelimitedFiles
using Quaternions

#-------------------------------------------------------------------- EXERCISE 2.2

V3 = [0; 0; 1] #vector of R3 we want to project in R2

function to_2d(V3)
    #we calculate de matrix (see the first exercise)

    a = 0.5*cosd(42)
    b = 0.5*sind(42)
    c = cosd(7)
    d = sind(7)
    e = 0
    f = 1

    M = [-a c e;
        -b -d f]
     #matrix found in the first exercise

    V2 = M*V3 #operation to transform V3 of R3 in V2 in R2

    # print("The vector ", V3, " representated in R2 is: ", V2)
    # println()

    return V2
end

#-------------------------------------------------------------------- EXERCISE 2.3
function rotate_phi_z(phi, z, V)
    Z = [0 -z[3] z[2];
         z[3] 0 -z[1];
        -z[2] z[1] 0]

    #formula de Rodriges to find "R", the rotation matrix
    R = I + sind(phi)*Z + (1-cosd(phi))*(Z^2)
    #just above, we multiply pi/180 to the angle (in degrees) to obtain the angle in radians
    #so julia can do the operation we want

    #next, we will check if R is a rotation matrix: R*R'=I and det(R)=1
    #For this comprobation, we needed to round R*R' and det(R). That's because much times
    #the result was 0.999999 and not 1
    if (round.(R*R') == I && round(det(R)) == 1)
        #we find the rotated matrix:
        U = R*V
        # print("V rotated is = ", U)
        # println()
        return U
    else
        print("R = ", R, "\nis NOT a rotation matrix\n")
        println("R*R'= ", round.(R*R'))
        println("det(R)= ", round(det(R)))

    end
end
