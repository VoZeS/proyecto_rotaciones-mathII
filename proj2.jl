using Printf
using LinearAlgebra
using DelimitedFiles
using Quaternions

#EXERCISE MADE BY ERIK MARTÍN GARZÓN & DAVID BOCES OBIS
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

#-------------------------------------------------------------------- EXERCISE 3.1
global axis_norm

function axis_angle_to_mat(axis, angle)
    #first, we normalize the axis
    modul = sqrt(axis[1]*axis[1] + axis[2]*axis[2] + axis[3]*axis[3])

    global axis_norm

    round(modul)

    if (modul == 0)
        return [1.0 0.0 0.0; 0.0 1.0 0.0; 0.0 0.0 1.0]
    else
        axis_norm = axis/modul

        Z = [0 -axis_norm[3] axis_norm[2];
             axis_norm[3] 0 -axis_norm[1];
            -axis_norm[2] axis_norm[1] 0]

        #formula Rodrigues
        R = I + sind(angle)*Z + (1-cosd(angle))*(Z^2)
        #just above, we multiply pi/180 to the angle (in degrees) to obtain the angle in radians
        #so julia can do the operation we want

        #next, we will check if R is a rotation matrix: R*R'=I and det(R)=1
        #For this comprobation, we needed to round R*R' and det(R). That's because much times
        #the result was 0.999999 and not 1
        if (round.(R*R')== I && round(det(R))==1)
            #we return the rotation matrix
            return R
        else
            print("R = ", R, "\nis NOT a rotation matrix\n")
            println("R*R'= ", round.(R*R'))
            println("det(R)= ", round(det(R)))
        end
    end
end

function mat_to_axis_angle(mat)
    #first, we find the angle:
    angle = acosd((tr(mat)-1)/2)

    #then, we find the axis:
    V = (mat-mat')/(2*sind(angle))
    v = [V[3,2]; V[1,3]; V[2,1]]

    #we return the angle in degrees
    return angle, v
end

function axis_angle_to_quat(axis, angle)
    global q2
    #first, we normalize the axis
    modul = sqrt(axis[1]*axis[1] + axis[2]*axis[2] + axis[3]*axis[3])

    global axis_norm = axis/modul

    q2 = quat(cosd(angle/2), sind(angle/2)*axis_norm[1], sind(angle/2)*axis_norm[2], sind(angle/2)*axis_norm[3])

    return q2
end

function quat_to_axis_angle(q3)

    norm = sqrt(q3.s*q3.s + q3.v1*q3.v1 + q3.v2*q3.v2 + q3.v3*q3.v3)

    global axis_norm = [0.0;0.0;0.0]

    if(norm == 0)
        angle3 = 0

        axis_norm[1] = 0
        axis_norm[2] = 0
        axis_norm[3] = 0

    else
        angle3 = 2*acosd(q3.s/norm)

        axis_norm[1] = (q3.v1/norm)/sind(angle3/2)
        axis_norm[2] = (q3.v2/norm)/sind(angle3/2)
        axis_norm[3] = (q3.v3/norm)/sind(angle3/2)

    end


    return angle3, axis_norm
end

function quat_to_mat(q)
    global matQuat = [((q.s)^2 + (q.v1)^2 - (q.v2)^2 - (q.v3)^2) (2*(q.v1)*(q.v2) - 2*(q.s)*(q.v3)) (2*(q.v1)*(q.v3) + 2*(q.s)*(q.v2));
            (2*(q.v1)*(q.v2) + 2*(q.s)*(q.v3)) ((q.s)^2 - (q.v1)^2 + (q.v2)^2 - (q.v3)^2) (2*(q.v2)*(q.v3) - 2*(q.s)*(q.v1));
            (2*(q.v1)*(q.v3) - 2*(q.s)*(q.v2)) (2*(q.v2)*(q.v3) + 2*(q.s)*(q.v1)) ((q.s)^2 - (q.v1)^2 - (q.v2)^2 + (q.v3)^2)]

    return matQuat
end

function mat_to_quat(mat)
    #first, we find the angle:
    angle2 = acosd((tr(mat)-1)/2)

    if (angle2 != 0)
        #then, we find the axis:
        V = (mat-mat')/(2*sind(angle2))
        v = [V[3,2]; V[1,3]; V[2,1]]

        q3 = quat(cosd(angle2/2), sind(angle2/2)*v[1], sind(angle2/2)*v[2], sind(angle2/2)*v[3])

        return q3
    else
        return "THIS ROTATION MATRIX [IDENTITY MATRIX] HAS NO AXIS. ITS ROTATION ANGLE IS 0 + 360*K [BEING K AN ENTER]. FOR THE RESULT THIS MATRIX HAS NO QUATERNION FORM."
    end
end

#-------------------------------------------------------------------- EXERCISE 4.3
function scale_and_translation(v2d, scale, point)

    v2d = v2d*scale

    movement = [0.0;0.0]
    v2dResult = [0.0;0.0]


    movement[1] = point[1] - v2d[1]
    movement[2] = point[2] - v2d[2]

    v2dResult[1] = v2d[1] + movement[1]
    v2dResult[2] = v2d[2] + movement[2]

    return v2dResult

end
