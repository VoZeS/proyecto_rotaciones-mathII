#EXERCISE MADE BY ERIK MARTÍN GARZÓN & DAVID BOCES OBIS
# the packages we need
using Gtk, Graphics, Logging, Printf

include("proj2.jl")

# the main window
win = GtkWindow("SO(3)")

function init_canvas(h,w)
    # create the drawing canvas
    c = @GtkCanvas(h,w)

    # create the initial drawing inside a try/catch loop
    @guarded draw(c) do widget
        #  draw the background with the canvas drawing context
        # the code for this comes later
        draw_the_canvas(c)
    end

    show(c)
    return c
end

# make the canvas
the_canvas = init_canvas(750,750)


# --------- part 2 -------------
# define all the widgets

# a widget for status messages that we define at the beginning so we can use it from the callback
msg_label = GtkLabel("No message at this time")

matrix_label1 = GtkLabel("")
matrix_label2 = GtkLabel("")
matrix_label3 = GtkLabel("")

global matrixR = [0.0 0.0 0.0; 0.0 0.0 0.0; 0.0 0.0 0.0]

# defaults
default_value = Dict("phi"=>0,"v_x"=>1,"v_y"=>0,"v_z"=>0,"alpha"=>70, "q0" => 0, "q1" => 0, "q2" => 0, "q3" => 0, "m1" => 0, "m2" => 0, "m3" => 0)

# an array to store the entry boxes
entry_list = []

# an array of labels that we use to display normalized inputs,
# and which also gets modified from the callback
normalized_labels = []

#we comprobate if quaternions change, for now, is false
quatChanged = false

function find_by_name(list, name)
    for item in list
        if get_gtk_property(item, :name, String) == name
            return item
        end
    end
    @warn name, "not found in list"
    @warn "available names are"
    for item in list
        @warn get_gtk_property(item, :name, String)
    end
end

function output_normalized(label, value)
    GAccessor.text(find_by_name(normalized_labels, label), @sprintf("%3.2f", value))
end

function normalize_v()
    v_x = read_original_box("v_x")
    v_y = read_original_box("v_y")
    v_z = read_original_box("v_z")

    norm = sqrt(v_x*v_x + v_y*v_y + v_z*v_z)

    if(norm!=0)
        output_normalized("v_x_normalized", v_x / norm)
        output_normalized("v_y_normalized", v_y / norm)
        output_normalized("v_z_normalized", v_z / norm)
    else
        output_normalized("v_x_normalized", 0)
        output_normalized("v_y_normalized", 0)
        output_normalized("v_z_normalized", 0)
    end
end

function normalize_q()
    q0 = read_original_box("q0")
    q1 = read_original_box("q1")
    q2 = read_original_box("q2")
    q3 = read_original_box("q3")

    normQ = sqrt(q0*q0 + q1*q1 + q2*q2 + q3*q3)

    if(normQ == 0)
        output_normalized("q0_normalized", 0)
        output_normalized("q1_normalized", 0)
        output_normalized("q2_normalized", 0)
        output_normalized("q3_normalized", 0)
    else
        output_normalized("q0_normalized", q0 / normQ)
        output_normalized("q1_normalized", q1 / normQ)
        output_normalized("q2_normalized", q2 / normQ)
        output_normalized("q3_normalized", q3 / normQ)

    end

end

function normalize_alpha()
    output_normalized("alpha_normalized", read_original_box("alpha"))
end

function normalize_phi()
    output_normalized("phi_normalized", read_original_box("phi"))
end

function matrix_box1()
    GAccessor.text(matrix_label1, string(matrixR[1,:]))
end

function matrix_box2()
    GAccessor.text(matrix_label2, string(matrixR[2,:]))
end

function matrix_box3()
    GAccessor.text(matrix_label3, string(matrixR[3,:]))
end


function entry_box_callback(widget)
    # who called us?
    name = get_gtk_property(widget, :name, String)
    text = get_gtk_property(widget, :text, String)

    get_gtk_property(widget, :name, String) == "matrixR"

    if (get_gtk_property(widget, :name, String) == "q0" ||
        get_gtk_property(widget, :name, String) == "q1" ||
        get_gtk_property(widget, :name, String) == "q2" ||
        get_gtk_property(widget, :name, String) == "q3")

        global quatChanged = true

    elseif (get_gtk_property(widget, :name, String) == "alpha" ||
            get_gtk_property(widget, :name, String) == "v_x" ||
            get_gtk_property(widget, :name, String) == "v_y" ||
            get_gtk_property(widget, :name, String) == "v_z")
        global quatChanged = false
    end

    # checking that we tell user alpha has limits at 0 and 180
    if (get_gtk_property(widget, :name, String) == "alpha" && read_original_box("alpha") < 0)
        GAccessor.text(msg_label, "alpha" * " changed to 0")

    elseif (get_gtk_property(widget, :name, String) == "alpha" && read_original_box("alpha") > 180)
        GAccessor.text(msg_label, "alpha" * " changed to 180" )

    else
        GAccessor.text(msg_label, name * " changed to " * text)
    end

    # change the correct normalized output
    if name[1] == 'v'
        normalize_v()
        matrix_box1()
        matrix_box2()
        matrix_box3()
    elseif name[1] == 'a'
        normalize_alpha()
        matrix_box1()
        matrix_box2()
        matrix_box3()
    elseif name[1] == 'p'
        normalize_phi()
        matrix_box1()
        matrix_box2()
        matrix_box3()
    elseif name[1] == 'q'
        normalize_q()
        matrix_box1()
        matrix_box2()
        matrix_box3()
    end

    # actually draw the changes
    draw_the_canvas(the_canvas)
    reveal(the_canvas)
end

function entry_box(label_string)
    # set up the entry
    entry = GtkEntry()
    set_gtk_property!(entry,:width_chars, 5)
    set_gtk_property!(entry,:max_length, 5)
    set_gtk_property!(entry,:name, label_string)

    default_text = string(default_value[label_string])
    GAccessor.text(entry, default_text)
    push!(entry_list, entry)

    # make it communicate changes
    signal_connect(entry_box_callback, entry, "changed")

    # set up the label and normalized output
    label = GtkLabel(label_string)
    normalized_output = GtkLabel(default_text)
    set_gtk_property!(normalized_output, :name, label_string * "_normalized")

    # make and return the containing box
    hbox = GtkButtonBox(:h)
    push!(hbox, label)
    push!(hbox, entry)
    push!(hbox, normalized_output)

    # export the normalized output for further use
    push!(normalized_labels, normalized_output)

    return hbox
end

function bold_label(label_string)
    label = GtkLabel("")
    GAccessor.markup(label, """<b>""" * label_string * """</b>""")
    return label
end

function phi_box()
    vbox = GtkBox(:v)
    push!(vbox, bold_label("Coordinate rotation"))
    push!(vbox, entry_box("phi"))
    return vbox
end

function vector_angle_box()
    vbox = GtkBox(:v)

    push!(vbox, bold_label("Axis"))

    for label in ["v_x", "v_y", "v_z"]
        push!(vbox, entry_box(label))
    end

    push!(vbox, bold_label("Angle"))

    push!(vbox, entry_box("alpha"))

    return vbox
end

function quaternion_box()
    vbox = GtkBox(:v)

    push!(vbox, bold_label("Quaternion"))
    push!(vbox, entry_box("q0"))
    push!(vbox, entry_box("q1"))
    push!(vbox, entry_box("q2"))
    push!(vbox, entry_box("q3"))
end

# Now put everything into the window,
# including the canvas
function init_window(win, canvas)

    # make a vertically stacked box for the data entry widgets
    control_box = GtkBox(:v)
    push!(control_box, phi_box())
    push!(control_box, GtkLabel(""))
    push!(control_box, vector_angle_box())
    push!(control_box, GtkLabel(""))
    push!(control_box, quaternion_box())
    push!(control_box, GtkLabel(""))
    push!(control_box, bold_label("Matrix"))
    push!(control_box, matrix_box1())
    push!(control_box, GtkLabel(""))
    push!(control_box, matrix_box2())
    push!(control_box, GtkLabel(""))
    push!(control_box, matrix_box3())
    push!(control_box, GtkLabel(""))
    push!(control_box, msg_label)

    # make another box for the drawing canvas
    canvas_box = GtkBox(:v)
    push!(canvas_box, canvas)

    # make a containing box that will stack the widgets and the canvas side by side
    global_box = GtkBox(:h)
    push!(global_box, control_box)
    push!(global_box, GtkLabel("   ")) # a very basic separator
    push!(global_box, canvas_box)

    # put it all inside the window
    push!(win, global_box)
end


# --------- part 3 -------------
# now we make the canvas interactive

function read_box(name, from_which_list, what)
    the_box = find_by_name(from_which_list, name)
    result = parse(Float64, get_gtk_property(the_box, what, String))
    return result
end

function read_original_box(name)
    return read_box(name, entry_list, :text)
end

function read_normalized_label(name)
    return read_box(name, normalized_labels, :label)
end

# the background drawing
function draw_the_canvas(canvas)
    h   = height(canvas)
    w   =  width(canvas)
    ctx =  getgc(canvas)

    # clear the canvas
    rectangle(ctx, 0, 0, w, h)
    set_source_rgb(ctx, 1, 1, 1)
    fill(ctx)

    # Paint red rectangle
    # rectangle(ctx, 3w/4, 0, w/4, h/4)
    # set_source_rgb(ctx, 1, 0, 0)
    # fill(ctx)

    # Paint blue rectangle
    # rectangle(ctx, 0, 3h/4, w/4, h/4)
    # set_source_rgb(ctx, 0, 0, 1)
    # fill(ctx)

    # Paint an example line
    # set_line_width(ctx, 5)
    # set_source_rgb(ctx, 1, 0, 1)
    # move_to(ctx, 10, 10)
    # line_to(ctx, 100, 50)
    # stroke(ctx)


    # read some normalized boxes and draw a line
    phi = 5  * read_normalized_label("phi_normalized")
    alpha = read_original_box("alpha") * 0.05
    v_x = 25 * read_normalized_label("v_x_normalized")
    v_y = 25 * read_normalized_label("v_y_normalized")
    v_z = 25 * read_normalized_label("v_z_normalized")

    q0 = read_normalized_label("q0_normalized")
    q1 = read_normalized_label("q1_normalized")
    q2 = read_normalized_label("q2_normalized")
    q3 = read_normalized_label("q3_normalized")

    q = quat(q0, q1, q2, q3)

    if(quatChanged == true)
        angle_axis = quat_to_axis_angle(q)

        alpha = angle_axis[1] * 0.05
        v_x = 25 * angle_axis[2][1]
        v_y = 25 * angle_axis[2][2]
        v_z = 25 * angle_axis[2][3]


        # println(angle_axis[1])
        # println(angle_axis[2])
    else
        qConverted = axis_angle_to_quat([v_x;v_y;v_z], alpha)

        q0 = qConverted.s
        q1 = qConverted.v1
        q2 = qConverted.v2
        q3 = qConverted.v3
    end


    global matrixR = axis_angle_to_mat([v_x;v_y;v_z], alpha)

    # println(alpha," ", q0," ", q1," ", q2," ", q3)


    if(alpha <= 0)
        alpha = 0
    end

    if(alpha >= 180*0.05)
        alpha = 180*0.05
    end

    #AXIS R3
    X = [1;0;0]
    Y = [0;1;0]
    Z = [0;0;1]

    v = [v_x; v_y; v_z]

    #WE ROTATE AXIS IN R3
    Xr = rotate_phi_z(phi, Z, X)
    Yr = rotate_phi_z(phi, Z, Y)
    Zr = rotate_phi_z(phi, Z, Z)

    vr = rotate_phi_z(phi, Z, v)

    # println("Alpha ", alpha*20)
    # println("Vr*alpha ", vr*alpha)
    # println("Xr ", Xr)

    Xvr = rotate_phi_z(alpha*20, vr*alpha, Xr)
    Yvr = rotate_phi_z(alpha*20, vr*alpha, Yr)
    Zvr = rotate_phi_z(alpha*20, vr*alpha, Zr)

    # println("Xvr ", Xvr)
    # println("Yvr ", Yvr)
    # println("Zvr ", Zvr)


    #AXIS IN R3 SCALED -VECTOR-
    Xv = scale_and_translation(Xvr*100, 0.25, vr*alpha)
    Yv = scale_and_translation(Yvr*100, 0.25, vr*alpha)
    Zv = scale_and_translation(Zvr*100, 0.25, vr*alpha)


    #WE PROJECT THE ROTATED AXIS IN R3 TO R2
    Xr2 = to_2d(Xr)
    Yr2 = to_2d(Yr)
    Zr2 = to_2d(Zr)

    #WE PROJECT THE ROTATED AXIS IN R3 TO R2
    Xvr2 = to_2d(Xv)
    Yvr2 = to_2d(Yv)
    Zvr2 = to_2d(Zv)

    #WE PROJECT THE ROTATED AXIS IN R3 TO R2
    X2 = to_2d(X)
    Y2 = to_2d(Y)
    Z2 = to_2d(Z)

    vr2 = to_2d(vr)

    #println("Xv ", Xv, "\nYv ", Yv, "\nZv ", Zv)

    #DRAW X AXIS (RED)
    set_line_width(ctx, 2)
    set_source_rgb(ctx, 1, 0, 0)
    move_to(ctx, 350, 350)
    line_to(ctx, 350 + Xr2[1]*100, 350 - Xr2[2]*100)
    stroke(ctx)

    #circle at the end of the axis
    circle(ctx, 350 + Xr2[1]*100, 350 - Xr2[2]*100, 5)
    set_source_rgb(ctx, 1, 0, 0)
    fill(ctx)

    #DRAW X AXIS SCALED -VECTOR- (RED)
    set_line_width(ctx, 2)
    set_source_rgb(ctx, 1, 0, 0)
    move_to(ctx, 350 + vr2[1]*alpha, 350 - vr2[2]*alpha)
    line_to(ctx, 350 + vr2[1] + Xvr2[1], 350 - vr2[2] - Xvr2[2])
    stroke(ctx)

    #circle at the end of the axis
    circle(ctx, 350 + vr2[1] + Xvr2[1], 350 - vr2[2] - Xvr2[2], 2)
    set_source_rgb(ctx, 1, 0, 0)
    fill(ctx)

    #DRAW Y AXIS (GREEN)
    set_line_width(ctx, 2)
    set_source_rgb(ctx, 0, 1, 0)
    move_to(ctx, 350, 350)
    line_to(ctx, 350 + Yr2[1]*100, 350 - Yr2[2]*100)
    stroke(ctx)

    #circle at the end of the axis
    circle(ctx, 350 + Yr2[1]*100, 350 - Yr2[2]*100, 5)
    set_source_rgb(ctx, 0, 1, 0)
    fill(ctx)

    #DRAW Y AXIS SCALED -VECTOR- (GREEN)
    set_line_width(ctx, 2)
    set_source_rgb(ctx, 0, 1, 0)
    move_to(ctx, 350 + vr2[1]*alpha, 350 - vr2[2]*alpha)
    line_to(ctx, 350 + vr2[1] + Yvr2[1], 350 - vr2[2] - Yvr2[2])
    stroke(ctx)

    #circle at the end of the axis
    circle(ctx, 350 + vr2[1] + Yvr2[1], 350 - vr2[2] - Yvr2[2], 2)
    set_source_rgb(ctx, 0, 1, 0)
    fill(ctx)

    #DRAW Z AXIS (BLUE)
    set_line_width(ctx, 2)
    set_source_rgb(ctx, 0, 0, 1)
    move_to(ctx, 350, 350)
    line_to(ctx, 350 + Zr2[1]*100, 350 - Zr2[2]*100)
    stroke(ctx)

    #circles at the end of the axis
    circle(ctx, 350 + Zr2[1]*100, 350 - Zr2[2]*100, 5)
    set_source_rgb(ctx, 0, 0, 1)
    fill(ctx)

    #DRAW Z AXIS SCALED -VECTOR- (BLUE)
    set_line_width(ctx, 2)
    set_source_rgb(ctx, 0, 0, 1)
    move_to(ctx, 350 + vr2[1]*alpha, 350 - vr2[2]*alpha)
    line_to(ctx, 350 + vr2[1] + Zvr2[1], 350 - vr2[2] - Zvr2[2])
    stroke(ctx)

    #circle at the end of the axis
    circle(ctx, 350 + vr2[1] + Zvr2[1], 350 - vr2[2] - Zvr2[2], 2)
    set_source_rgb(ctx, 0, 0, 1)
    fill(ctx)

    #DRAW VECTOR (BLACK)
    set_line_width(ctx, 2)
    set_source_rgb(ctx, 0, 0, 0)

    if (350+vr2[1]*alpha>1000 ||350 - vr2[2]*alpha>1000 )
        move_to(ctx, 350, 350)
        line_to(ctx, 350, 350)
    else
        move_to(ctx, 350, 350)
        line_to(ctx, 350 + vr2[1]*alpha, 350 - vr2[2]*alpha)
    end
    stroke(ctx)

    #circles at the end of the axis
    circle(ctx, 350 + vr2[1]*alpha, 350 - vr2[2]*alpha, 3)
    set_source_rgb(ctx, 0, 0, 0)
    fill(ctx)

end

# -------- initialize everything ---------


# prepare and show the initial widgets
init_window(win, the_canvas)
showall(win)
