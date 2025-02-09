const bindings = @import("./bindings.zig");

pub const width: i32 = 240;
pub const height: i32 = 160;

const pi: f32 = 3.14159265358979323846264338327950288;
const tau: f32 = 6.28318530717958647692528676655900577;

pub const Point = struct {
    x: i32,
    y: i32,
};

pub const Size = struct {
    width: i32,
    height: i32,
};

pub const Angle = struct {
    radians: f32,

    /// The 360° angle.
    pub const full_circle: Angle = Angle(tau);
    /// The 180° angle.
    pub const half_circle: Angle = Angle(pi);
    /// The 90° angle.
    pub const quarter_circle: Angle = Angle(pi / 2.0);
    /// The 0° angle.
    pub const zero: Angle = Angle(0.0);

    /// An angle in radians where Tau (doubled Pi) is the full circle.
    pub fn from_radians(r: f32) Angle {
        return Angle{r};
    }

    /// An angle in degrees where 360.0 is the full circle.
    pub fn from_degrees(d: f32) Angle {
        return Angle{d * pi / 180.0};
    }
};

pub const RGB = struct {
    r: u8,
    g: u8,
    b: u8,
};

pub const Color = enum(i32) {
    none,
    black,
    purple,
    red,
    orange,
    yellow,
    light_green,
    green,
    dark_green,
    dark_blue,
    blue,
    light_blue,
    cyan,
    white,
    light_gray,
    gray,
    dark_gray,
};

pub const Style = struct {
    fill_color: Color,
    stroke_color: Color,
    stroke_width: i32,
};

pub const LineStyle = struct {
    color: Color,
    width: i32,
};

pub const File = []u8;
pub const Font = File;
pub const Image = File;
pub const Canvas = Image;
pub const String = []u8;

pub const SubImage = struct {
    point: Point,
    size: Size,
    raw: []u8,
};

/// Fill the whole frame with the given color.
pub fn clearScreen(c: Color) void {
    bindings.clear_screen(@intFromEnum(c));
}

/// Set a color value in the palette.
pub fn setColor(c: Color, v: RGB) void {
    bindings.set_color(@intFromEnum(c), v.r, v.g, v.b);
}

/// Set a single point (1 pixel is scaling is 1) on the frame.
pub fn drawPoint(p: Point, c: Color) void {
    bindings.draw_point(p.x, p.y, @intFromEnum(c));
}

/// Draw a straight line from point a to point b.
pub fn drawLine(a: Point, b: Point, s: LineStyle) void {
    bindings.draw_line(a.x, a.y, b.x, b.y, s.color, s.width);
}

/// Draw a rectangle filling the given bounding box.
pub fn drawRect(p: Point, b: Size, s: Style) void {
    bindings.draw_rect(
        p.x,
        p.y,
        b.width,
        b.height,
        @intFromEnum(s.fill_color),
        @intFromEnum(s.stroke_color),
        s.stroke_width,
    );
}

/// Draw a rectangle with rounded corners.
pub fn drawRoundedRect(p: Point, b: Size, corner: Size, s: Style) void {
    bindings.draw_rounded_rect(
        p.x,
        p.y,
        b.width,
        b.height,
        corner.width,
        corner.height,
        @intFromEnum(s.fill_color),
        @intFromEnum(s.stroke_color),
        s.stroke_width,
    );
}

/// Draw a circle with the given diameter.
pub fn drawCircle(p: Point, d: i32, s: Style) void {
    bindings.draw_circle(
        p.x,
        p.y,
        d,
        @intFromEnum(s.fill_color),
        @intFromEnum(s.stroke_color),
        s.stroke_width,
    );
}

/// Draw an ellipse (oval).
pub fn drawEllipse(p: Point, b: Size, s: Style) void {
    bindings.draw_ellipse(
        p.x,
        p.y,
        b.width,
        b.height,
        @intFromEnum(s.fill_color),
        @intFromEnum(s.stroke_color),
        s.stroke_width,
    );
}

/// Draw a triangle.
///
/// The order of points doesn't matter.
pub fn drawTriangle(a: Point, b: Point, c: Point, s: Style) void {
    bindings.draw_triangle(
        a.x,
        a.y,
        b.x,
        b.y,
        c.x,
        c.y,
        @intFromEnum(s.fill_color),
        @intFromEnum(s.stroke_color),
        s.stroke_width,
    );
}

/// Draw an arc.
pub fn drawArc(p: Point, d: i32, start: Angle, sweep: Angle, s: Style) void {
    bindings.draw_arc(
        p.x,
        p.y,
        d,
        start.radians,
        sweep.radians,
        @intFromEnum(s.fill_color),
        @intFromEnum(s.stroke_color),
        s.stroke_width,
    );
}

/// Draw a sector.
pub fn drawSector(p: Point, d: i32, start: Angle, sweep: Angle, s: Style) void {
    bindings.draw_sector(
        p.x,
        p.y,
        d,
        start.radians,
        sweep.radians,
        @intFromEnum(s.fill_color),
        @intFromEnum(s.stroke_color),
        s.stroke_width,
    );
}

/// Render text using the given font.
///
/// Unlike in the other drawing functions, here [Point] points not to the top-left corner
/// but to the baseline start position.
pub fn drawText(t: String, f: Font, p: Point, c: Color) void {
    bindings.draw_text(
        t.ptr,
        t.len,
        f.ptr,
        f.len,
        p.x,
        p.y,
        @intFromEnum(c),
    );
}

/// Render an image using the given colors.
pub fn drawImage(i: Image, p: Point) void {
    bindings.draw_image(i.ptr, i.len, p.x, p.y);
}

/// Draw a subregion of an image.
///
/// Most often used to draw a sprite from a sprite atlas.
pub fn drawSubImage(i: SubImage, p: Point) void {
    bindings.draw_sub_image(
        i.raw.ptr,
        i.raw.len,
        p.x,
        p.y,
        i.point.x,
        i.point.y,
        i.size.width,
        i.size.height,
    );
}

/// Set canvas to be used for all subsequent drawing operations.
pub fn setCanvas(c: Canvas) void {
    bindings.set_canvas(c.ptr, c.len);
}

/// Unset canvas set by [`set_canvas`]. All subsequent drawing operations will target frame buffer.
pub fn unsetCanvas() void {
    bindings.unset_canvas();
}
