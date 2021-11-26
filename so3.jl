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
the_canvas = init_canvas(500,500)


# --------- part 2 -------------
# define all the widgets

# a widget for status messages that we define at the beginning so we can use it from the callback
msg_label = GtkLabel("No message at this time")

# defaults
default_value = Dict("phi" => 0, "v_x" => 1, "v_y" => 0, "v_z" => 0, "alpha" => 70)

# an array to store the entry boxes
entry_list = []

# an array of labels that we use to display normalized inputs,
# and which also gets modified from the callback
normalized_labels = []

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

    output_normalized("v_x_normalized", v_x / norm)
    output_normalized("v_y_normalized", v_y / norm)
    output_normalized("v_z_normalized", v_z / norm)
end

function normalize_alpha()
    output_normalized("alpha_normalized", read_original_box("alpha"))
end

function normalize_phi()
    output_normalized("phi_normalized", read_original_box("phi"))
end

function entry_box_callback(widget)
    # who called us?
    name = get_gtk_property(widget, :name, String)
    text = get_gtk_property(widget, :text, String)

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
    elseif name[1] == 'a'
        normalize_alpha()
    elseif name[1] == 'p'
        normalize_phi()
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

# Now put everything into the window,
# including the canvas

function init_window(win, canvas)

    # make a vertically stacked box for the data entry widgets
    control_box = GtkBox(:v)
    push!(control_box, phi_box())
    push!(control_box, GtkLabel(""))
    push!(control_box, vector_angle_box())
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
    rectangle(ctx, 3w/4, 0, w/4, h/4)
    set_source_rgb(ctx, 1, 0, 0)
    fill(ctx)

    # Paint blue rectangle
    rectangle(ctx, 0, 3h/4, w/4, h/4)
    set_source_rgb(ctx, 0, 0, 1)
    fill(ctx)

    # Paint an example line
    # set_line_width(ctx, 5)
    # set_source_rgb(ctx, 1, 0, 1)
    # move_to(ctx, 10, 10)
    # line_to(ctx, 100, 50)
    # stroke(ctx)


    # read some normalized boxes and draw a line
    phi = 5  * read_normalized_label("phi_normalized")
    v_x = 50 * read_normalized_label("v_x_normalized")
    v_y = 50 * read_normalized_label("v_y_normalized")
    v_z = 50 * read_normalized_label("v_z_normalized")

    alpha = read_original_box("alpha")

    if(alpha <= 0)
        alpha = 0
    end

    if(alpha >= 180)
        alpha = 180
    end

    #AXIS R3
    X = [1;0;0]
    Y = [0;1;0]
    Z = [0;0;1]

    v = [v_x; v_y; v_z]

    #WE ROTATE AXIS IN R3
    Xr = rotate_phi_z(phi, z, X)
    Yr = rotate_phi_z(phi, z, Y)
    Zr = rotate_phi_z(phi, z, Z)

    vr = rotate_phi_z(phi, z, v)

    #WE PROJECT THE ROTATED AXIS IN R3 TO R2
    Xr2 = to_2d(Xr)
    Yr2 = to_2d(Yr)
    Zr2 = to_2d(Zr)

    vr2 = to_2d(vr)

    #DRAW X AXIS (RED)
    set_line_width(ctx, 2)
    set_source_rgb(ctx, 1, 0, 0)
    move_to(ctx, 200, 200)
    line_to(ctx, 200 + Xr2[1]*100, 200 - Xr2[2]*100)
    stroke(ctx)

    #circle at the end of the axis
    circle(ctx, 200 + Xr2[1]*100, 200 - Xr2[2]*100, 5)
    set_source_rgb(ctx, 1, 0, 0)
    fill(ctx)

    #DRAW Y AXIS (GREEN)
    set_line_width(ctx, 2)
    set_source_rgb(ctx, 0, 1, 0)
    move_to(ctx, 200, 200)
    line_to(ctx, 200 + Yr2[1]*100, 200 - Yr2[2]*100)
    stroke(ctx)

    #circle at the end of the axis
    circle(ctx, 200 + Yr2[1]*100, 200 - Yr2[2]*100, 5)
    set_source_rgb(ctx, 0, 1, 0)
    fill(ctx)

    #DRAW Z AXIS (BLUE)
    set_line_width(ctx, 2)
    set_source_rgb(ctx, 0, 0, 1)
    move_to(ctx, 200, 200)
    line_to(ctx, 200 + Zr2[1]*100, 200 - Zr2[2]*100)
    stroke(ctx)

    #circles at the end of the axis
    circle(ctx, 200 + Zr2[1]*100, 200 - Zr2[2]*100, 5)
    set_source_rgb(ctx, 0, 0, 1)
    fill(ctx)

    #DRAW VECTOR (BLACK)
    set_line_width(ctx, 2)
    set_source_rgb(ctx, 0, 0, 0)
    move_to(ctx, 200, 200)
    line_to(ctx, 200 + vr2[1]*alpha, 200 - vr2[2]*alpha)
    stroke(ctx)

end

# -------- initialize everything ---------


# prepare and show the initial widgets
init_window(win, the_canvas)
showall(win)
