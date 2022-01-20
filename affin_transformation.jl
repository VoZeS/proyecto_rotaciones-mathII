using Printf
using LinearAlgebra
using DelimitedFiles
using Quaternions

#EXERCISE MADE BY ERIK MARTÍN GARZÓN & DAVID BOCES OBIS

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

    # println("The vector ", V3, " representated in R2 is: ", V2)
    # println()

    return V2
end

function rotate_phi_z(phi, z, V)

    global z_norm
    global z_module

    z_module = sqrt(z[1]*z[1]+z[2]*z[2]+z[3]*z[3])

    z_norm = z/z_module

    Z = [0.0 -z_norm[3] z_norm[2];
         z_norm[3] 0.0 -z_norm[1];
        -z_norm[2] z_norm[1] 0.0]

    #formula de Rodriges to find "R", the rotation matrix
    R = I + sind(phi)*Z + (1-cosd(phi))*(Z^2)
    #just above, we multiply pi/180 to the angle (in degrees) to obtain the angle in radians
    #so julia can do the operation we want

    #next, we will check if R is a rotation matrix: R*R'=I and det(R)=1
    #For this comprobation, we needed to round R*R' and det(R). That's because much times
    #the result was 0.999999 and not 1
    if(phi==0)
        return V
    end
    if (z != [0.0;0.0;0.0])
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
    else

            return [0.0 0.0 0.0; 0.0 0.0 0.0;0.0 0.0 0.0]
    end
end

function focal_camera(cameraMatrixInv, focus, point)
    projMat=[focus 0 0 0; 0 focus 0 0;  0 0 1 0]

    pointHomo = vcat(point, [1])

    finalPoint=projMat*cameraMatrixInv*pointHomo

    finalPointHomo = [finalPoint[1]/finalPoint[3];finalPoint[2]/finalPoint[3]; finalPoint[3]/finalPoint[3]]

    return finalPointHomo
end

function focal_camera_points_in_space(cameraMatrix, focus, point2d)
    pointHomo = vcat(point2d, [focus; 1])

    point_in_space = cameraMatrix * pointHomo

    return point_in_space
end
