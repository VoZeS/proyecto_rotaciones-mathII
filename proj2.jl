using Printf
using LinearAlgebra
using DelimitedFiles

#-------------------------------------------------------------------- EXERCISE 2.2

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

    # print("The vector ", V3, " representated in R2 is: ", V2)
    # println()

    return V2
end

#-------------------------------------------------------------------- EXERCISE 2.3
function rotate_phi_z(phi, z, V)
    Z = [0 -z[3,1] z[2,1];
         z[3,1] 0 -z[1,1];
        -z[2,1] z[1,1] 0]

    #formula de Rodriges to find "R", the rotation matrix
    R = I + Z*sin(phi*pi/180) + Z^2*(1-cos(phi*pi/180))
    #just above, we multiply pi/180 to the angle (in degrees) to obtain the angle in radians
    #so julia can do the operation we want

    #next, we will check if R is a rotation matrix: R*R'=I and det(R)=1
    if (R*R'==I && det(R)==1)
        #we find the rotated matrix:
        U = R*V
        # print("V rotated is = ", U)
        # println()
        return U
    else
        print("R = ", R, "\nis NOT a rotation matrix\n")

    end
end

#-------------------------------------------------------------------- EXERCISE 3.1
angle = 90 #degrees
axis = [0;0;1] #axis z

function axis_angle_to_mat(axis, angle)
    Z = [0 -axis[3,1] axis[2,1];
         axis[3,1] 0 -axis[1,1];
        -axis[2,1] axis[1,1] 0]

    #formula Rodrigues
    R = I + Z*sin(angle*pi/180) + Z^2*(1-cos(angle*pi/180))
    #just above, we multiply pi/180 to the angle (in degrees) to obtain the angle in radians
    #so julia can do the operation we want

    #next, we will check if R is a rotation matrix: R*R'=I and det(R)=1
    if (R*R'== I && det(R)==1)
        #we return the rotation matrix
        return R
    else
        print("R = ", R, "\nis NOT a rotation matrix\n")
    end
end

function mat_to_axis_angle(mat)
    #first, we find the angle:
    angle = acos((tr(mat)-1)/2)

    #then, we find the axis:
    V = (mat-mat')/(2*sin(angle))
    v = [V[3,2]; V[1,3]; V[2,1]]

    #we return the angle in degrees
    return angle*(180/pi), v
end

mat = axis_angle_to_mat(axis, angle)

mat_to_axis_angle(mat)

q = quat(1,0,0,0)

function quat_to_mat(q)
    mat = [((q.s)^2 + (q.v1)^2 - (q.v2)^2 - (q.v3)^2) (2*(q.v1)*(q.v2) - 2*(q.s)*(q.v3)) (2*(q.v1)*(q.v3) + 2*(q.s)*(q.v2));
            (2*(q.v1)*(q.v2) + 2*(q.s)*(q.v3)) ((q.s)^2 - (q.v1)^2 + (q.v2)^2 - (q.v3)^2) (2*(q.v2)*(q.v3) - 2*(q.s)*(q.v1));
            (2*(q.v1)*(q.v3) - 2*(q.s)*(q.v2)) (2*(q.v2)*(q.v3) + 2*(q.s)*(q.v1)) ((q.s)^2 - (q.v1)^2 - (q.v2)^2 + (q.v3)^2)]

    return mat
end

quat_to_mat(q)

function mat_to_quat(mat)

end

function quat_to_axis_angle(quat)

end

function axis_angle_to_quat(axis, angle)

end 
