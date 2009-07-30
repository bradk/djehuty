/*
 * graphics.d
 *
 * This Scaffold holds the Graphics implementations for the Linux platform
 *
 * Author: Dave Wilkinson
 *
 */

module scaffold.graphics;

import core.string;
import core.color;
import core.main;
import core.definitions;
import core.string;

import graphics.view;
import graphics.graphics;

import platform.unix.common;
import platform.unix.main;

import platform.vars.view;
import platform.vars.region;
import platform.vars.brush;
import platform.vars.pen;
import platform.vars.font;

import graphics.region;

// Shapes

// Draw a line
void drawLine(ViewPlatformVars* viewVars, int x, int y, int x2, int y2)
{
	if (x2 > x) { x2--; } else if (x2 < x) { x2++; }
	if (y2 > y) { y2--; } else if (y2 < y) { y2++; }

	X.XDrawLine(_pfvars.display, viewVars.pixmap, viewVars.gc, (x), (y), (x2), (y2));
}

// Draw a rectangle (filled with the current brush, outlined with current pen)
void drawRect(ViewPlatformVars* viewVars, int x, int y, int x2, int y2)
{
	if (x2 > x) { x2--; } else if (x2 < x) { x2++; }
	if (y2 > y) { y2--; } else if (y2 < y) { y2++; }

	X.XSetForeground(_pfvars.display, viewVars.gc, viewVars.curbrush);
	X.XFillRectangle(_pfvars.display, viewVars.pixmap, viewVars.gc, (x), (y), (x2)-(x), (y2)-(y));
	X.XSetForeground(_pfvars.display, viewVars.gc, viewVars.curpen);
	X.XDrawRectangle(_pfvars.display, viewVars.pixmap, viewVars.gc, (x), (y), (x2)-(x), (y2)-(y));
}

// Draw an ellipse (filled with current brush, outlined with current pen)
void drawOval(ViewPlatformVars* viewVars, int x, int y, int x2, int y2)
{
	if (x2 > x) { x2--; } else if (x2 < x) { x2++; }
	if (y2 > y) { y2--; } else if (y2 < y) { y2++; }

	X.XSetForeground(_pfvars.display, viewVars.gc, viewVars.curbrush);
	X.XFillArc(_pfvars.display, viewVars.pixmap, viewVars.gc, (x), (y), (x2)-(x), (y2)-(y), 0, 360*64);
	X.XSetForeground(_pfvars.display, viewVars.gc, viewVars.curpen);
	X.XDrawArc(_pfvars.display, viewVars.pixmap, viewVars.gc, (x), (y), (x2)-(x), (y2)-(y), 0, 360*64);
}




// Fonts

//void createFont(ViewPlatformVars* viewVars, out Font font, string fontname, int fontsize, int weight, bool italic, bool underline, bool strikethru)
void createFont(FontPlatformVars* font, string fontname, int fontsize, int weight, bool italic, bool underline, bool strikethru)
{
	font.pangoFont = Pango.pango_font_description_new();

	String fontnamestr = new String(fontname);
	fontnamestr.appendChar('\0');

	Pango.pango_font_description_set_family(font.pangoFont, fontnamestr.ptr);
	Pango.pango_font_description_set_size(font.pangoFont, fontsize * Pango.PANGO_SCALE);

	if (italic)
	{
		Pango.pango_font_description_set_style(font.pangoFont, Pango.PangoStyle.PANGO_STYLE_ITALIC);
	}
	else
	{
		Pango.pango_font_description_set_style(font.pangoFont, Pango.PangoStyle.PANGO_STYLE_NORMAL);
	}

	Pango.pango_font_description_set_weight(font.pangoFont, cast(Pango.PangoWeight)(weight));
}

//void createFont(ViewPlatformVars* viewVars, out Font font, String fontname, int fontsize, int weight, bool italic, bool underline, bool strikethru)
void createFont(FontPlatformVars* font, String fontname, int fontsize, int weight, bool italic, bool underline, bool strikethru)
{
	font.pangoFont = Pango.pango_font_description_new();

	fontname = new String(fontname);
	fontname.appendChar('\0');

	Pango.pango_font_description_set_family(font.pangoFont, fontname.ptr);
	Pango.pango_font_description_set_size(font.pangoFont, fontsize * Pango.PANGO_SCALE);

	if (italic)
	{
		Pango.pango_font_description_set_style(font.pangoFont, Pango.PangoStyle.PANGO_STYLE_ITALIC);
	}
	else
	{
		Pango.pango_font_description_set_style(font.pangoFont, Pango.PangoStyle.PANGO_STYLE_NORMAL);
	}

	Pango.pango_font_description_set_weight(font.pangoFont, cast(Pango.PangoWeight)(weight));
}

void setFont(ViewPlatformVars* viewVars, FontPlatformVars* font)
{
	Pango.pango_layout_set_font_description(viewVars.layout, font.pangoFont);
}

void destroyFont(FontPlatformVars* font)
{
	Pango.pango_font_description_free(font.pangoFont);
}



// Text
void drawText(ViewPlatformVars* viewVars, int x, int y, String str)
{
	Pango.pango_layout_set_text(viewVars.layout, str.ptr, str.length);

	Cairo.cairo_set_source_rgb(viewVars.cr, viewVars.textclr_red, viewVars.textclr_green, viewVars.textclr_blue);

	Cairo.cairo_move_to(viewVars.cr, (x), (y));

	Pango.pango_cairo_show_layout(viewVars.cr, viewVars.layout);
}

void drawText(ViewPlatformVars* viewVars, int x, int y, string str)
{
	Pango.pango_layout_set_text(viewVars.layout, str.ptr, str.length);

	Cairo.cairo_set_source_rgb(viewVars.cr, viewVars.textclr_red, viewVars.textclr_green, viewVars.textclr_blue);

	Cairo.cairo_move_to(viewVars.cr, (x), (y));

	Pango.pango_cairo_show_layout(viewVars.cr, viewVars.layout);
}

void drawText(ViewPlatformVars* viewVars, int x, int y, String str, uint length)
{
	Pango.pango_layout_set_text(viewVars.layout, str.ptr, length);

	Cairo.cairo_set_source_rgb(viewVars.cr, viewVars.textclr_red, viewVars.textclr_green, viewVars.textclr_blue);

	Cairo.cairo_move_to(viewVars.cr, (x), (y));

	Pango.pango_cairo_show_layout(viewVars.cr, viewVars.layout);
}

void drawText(ViewPlatformVars* viewVars, int x, int y, string str, uint length)
{
	Pango.pango_layout_set_text(viewVars.layout, str.ptr, length);

	Cairo.cairo_set_source_rgb(viewVars.cr, viewVars.textclr_red, viewVars.textclr_green, viewVars.textclr_blue);

	Cairo.cairo_move_to(viewVars.cr, (x), (y));

	Pango.pango_cairo_show_layout(viewVars.cr, viewVars.layout);
}

// Clipped Text
void drawClippedText(ViewPlatformVars* viewVars, int x, int y, Rect region, String str)
{
//		drawText(x,y,str);

	/*
	Pango.pango_layout_set_text(viewVars.layout, str.ptr, str.length);

	double xp1,yp1,xp2,yp2;

	printf("clip draw start\n");

	xp1 = region.left;
	yp1 = region.top;
	xp2 = region.right;
	yp2 = region.bottom;

	Cairo.cairo_save(viewVars.cr);

	printf("clip draw a\n");

	Cairo.cairo_rectangle(viewVars.cr, xp1, yp1, xp2, yp2);
	Cairo.cairo_clip(viewVars.cr);

	printf("clip draw a\n");

	Cairo.cairo_set_source_rgb(viewVars.cr, viewVars.textclr_red, viewVars.textclr_green, viewVars.textclr_blue);

	printf("clip draw a\n");

	Cairo.cairo_move_to(viewVars.cr, (x), (y));

	printf("clip draw a\n");

	Pango.pango_cairo_show_layout(viewVars.cr, viewVars.layout);

	printf("clip draw a\n");

	Cairo.cairo_restore(viewVars.cr);

	printf("clip draw done\n"); */
}

void drawClippedText(ViewPlatformVars* viewVars, int x, int y, Rect region, string str)
{
	Pango.pango_layout_set_text(viewVars.layout, str.ptr, str.length);

	double xp1,yp1,xp2,yp2;

	xp1 = region.left;
	yp1 = region.top;
	xp2 = region.right;
	yp2 = region.bottom;

	Cairo.cairo_save(viewVars.cr);

	Cairo.cairo_rectangle(viewVars.cr, xp1, yp1, xp2, yp2);
	Cairo.cairo_clip(viewVars.cr);

	Cairo.cairo_set_source_rgb(viewVars.cr, viewVars.textclr_red, viewVars.textclr_green, viewVars.textclr_blue);

	Cairo.cairo_move_to(viewVars.cr, (x), (y));

	Pango.pango_cairo_show_layout(viewVars.cr, viewVars.layout);

	Cairo.cairo_restore(viewVars.cr);
}

void drawClippedText(ViewPlatformVars* viewVars, int x, int y, Rect region, String str, uint length)
{
	Pango.pango_layout_set_text(viewVars.layout, str.ptr, length);

	double xp1,yp1,xp2,yp2;

	xp1 = region.left;
	yp1 = region.top;
	xp2 = region.right;
	yp2 = region.bottom;

	Cairo.cairo_save(viewVars.cr);

	Cairo.cairo_rectangle(viewVars.cr, xp1, yp1, xp2, yp2);
	Cairo.cairo_clip(viewVars.cr);

	Cairo.cairo_set_source_rgb(viewVars.cr, viewVars.textclr_red, viewVars.textclr_green, viewVars.textclr_blue);

	Cairo.cairo_move_to(viewVars.cr, (x), (y));

	Pango.pango_cairo_show_layout(viewVars.cr, viewVars.layout);

	Cairo.cairo_restore(viewVars.cr);
}

void drawClippedText(ViewPlatformVars* viewVars, int x, int y, Rect region, string str, uint length)
{
	Pango.pango_layout_set_text(viewVars.layout, str.ptr, length);

	double xp1,yp1,xp2,yp2;

	xp1 = region.left;
	yp1 = region.top;
	xp2 = region.right;
	yp2 = region.bottom;

	Cairo.cairo_save(viewVars.cr);

	Cairo.cairo_rectangle(viewVars.cr, xp1, yp1, xp2, yp2);
	Cairo.cairo_clip(viewVars.cr);

	Cairo.cairo_set_source_rgb(viewVars.cr, viewVars.textclr_red, viewVars.textclr_green, viewVars.textclr_blue);

	Cairo.cairo_move_to(viewVars.cr, (x), (y));

	Pango.pango_cairo_show_layout(viewVars.cr, viewVars.layout);

	Cairo.cairo_restore(viewVars.cr);
}

// Text Measurement
void measureText(ViewPlatformVars* viewVars, String str, out Size sz)
{
	Pango.pango_layout_set_text(viewVars.layout,
		str.ptr, str.length);

	Pango.pango_layout_get_size(viewVars.layout, cast(int*)&sz.x, cast(int*)&sz.y);

	sz.x /= Pango.PANGO_SCALE;
	sz.y /= Pango.PANGO_SCALE;
}

void measureText(ViewPlatformVars* viewVars, String str, uint length, out Size sz)
{
	Pango.pango_layout_set_text(viewVars.layout,
		str.ptr, length);

	Pango.pango_layout_get_size(viewVars.layout, cast(int*)&sz.x, cast(int*)&sz.y);

	sz.x /= Pango.PANGO_SCALE;
	sz.y /= Pango.PANGO_SCALE;
}

void measureText(ViewPlatformVars* viewVars, string str, out Size sz)
{
	Pango.pango_layout_set_text(viewVars.layout,
		str.ptr, str.length);

	Pango.pango_layout_get_size(viewVars.layout, cast(int*)&sz.x, cast(int*)&sz.y);

	sz.x /= Pango.PANGO_SCALE;
	sz.y /= Pango.PANGO_SCALE;
}

void measureText(ViewPlatformVars* viewVars, string str, uint length, out Size sz)
{
	Pango.pango_layout_set_text(viewVars.layout,
		str.ptr, length);

	Pango.pango_layout_get_size(viewVars.layout, cast(int*)&sz.x, cast(int*)&sz.y);

	sz.x /= Pango.PANGO_SCALE;
	sz.y /= Pango.PANGO_SCALE;
}

// Text Colors
void setTextBackgroundColor(ViewPlatformVars* viewVars, ref Color textColor)
{
	// Color is an INT
	// divide

	int r, g, b;

	r = ColorGetR(textColor) * 0x101;
	g = ColorGetG(textColor) * 0x101;
	b = ColorGetB(textColor) * 0x101;

	viewVars.attr_bg = Pango.pango_attr_background_new(r, g, b);

	viewVars.attr_bg.start_index = 0;
	viewVars.attr_bg.end_index = -1;

//Pango.pango_attr_list_insert(viewVars.attr_list_opaque, viewVars.attr_bg);
	Pango.pango_attr_list_change(viewVars.attr_list_opaque, viewVars.attr_bg);

//		Pango.pango_attribute_destroy(viewVars.attr_bg);
}

void setTextColor(ViewPlatformVars* viewVars, ref Color textColor)
{
	// Color is an INT
	// divide

	double r, g, b;

	r = ColorGetR(textColor);
	g = ColorGetG(textColor);
	b = ColorGetB(textColor);

	viewVars.textclr_red = r / 255.0;
	viewVars.textclr_green = g / 255.0;
	viewVars.textclr_blue = b / 255.0;
}

// Text States

void setTextModeTransparent(ViewPlatformVars* viewVars)
{
	Pango.pango_layout_set_attributes(viewVars.layout, viewVars.attr_list_transparent);
}

void setTextModeOpaque(ViewPlatformVars* viewVars)
{
	Pango.pango_layout_set_attributes(viewVars.layout, viewVars.attr_list_opaque);
}

// Brushes

void createBrush(BrushPlatformVars* brush, ref Color clr)
{
	brush.val = ColorGetValue(clr);
}

void setBrush(ViewPlatformVars* viewVars, BrushPlatformVars* brush)
{
	viewVars.curbrush = brush.val;
	X.XSetBackground(_pfvars.display, viewVars.gc, viewVars.curbrush);
}
void destroyBrush(BrushPlatformVars* brush)
{
}

// Pens

void createPen(PenPlatformVars* pen, ref Color clr)
{
	pen.val = ColorGetValue(clr);
}

void setPen(ViewPlatformVars* viewVars, PenPlatformVars* pen)
{
	viewVars.curpen = pen.val;
	X.XSetForeground(_pfvars.display, viewVars.gc, viewVars.curpen);
}

void destroyPen(PenPlatformVars* pen)
{
}

// View Interfacing

void drawView(ref ViewPlatformVars* viewVars, ref View view, int x, int y, ref ViewPlatformVars* viewVarsSrc, ref View srcView)
{
	Cairo.cairo_set_source_surface(viewVars.cr, viewVarsSrc.surface, x, y);
	Cairo.cairo_paint(viewVars.cr);
}

void drawView(ref ViewPlatformVars* viewVars, ref View view, int x, int y, ref ViewPlatformVars* viewVarsSrc, ref View srcView, int viewX, int viewY)
{
	Cairo.cairo_set_source_surface(viewVars.cr, viewVarsSrc.surface, x - viewX, y - viewY);
	double x1,y1,x2,y2;
	x1 = x;
	y1 = y;
	x2 = view.width() - viewX;
	y2 = view.height() - viewY;
	Cairo.cairo_rectangle(viewVars.cr, x1, y1, x2, y2);
	Cairo.cairo_fill(viewVars.cr);
}

void drawView(ref ViewPlatformVars* viewVars, ref View view, int x, int y, ref ViewPlatformVars* viewVarsSrc, ref View srcView, int viewX, int viewY, int viewWidth, int viewHeight)
{
	Cairo.cairo_set_source_surface(viewVars.cr, viewVarsSrc.surface, x - viewX, y - viewY);
	double x1,y1,x2,y2;
	x1 = x;
	y1 = y;
	x2 = viewWidth;
	y2 = viewHeight;
	Cairo.cairo_rectangle(viewVars.cr, x1, y1, x2, y2);
	Cairo.cairo_fill(viewVars.cr);
}

void drawView(ref ViewPlatformVars* viewVars, ref View view, int x, int y, ref ViewPlatformVars* viewVarsSrc, ref View srcView, double opacity)
{
	Cairo.cairo_set_source_surface(viewVars.cr, viewVarsSrc.surface, x, y);
	Cairo.cairo_paint_with_alpha(viewVars.cr, opacity);
}

void drawView(ref ViewPlatformVars* viewVars, ref View view, int x, int y, ref ViewPlatformVars* viewVarsSrc, ref View srcView, int viewX, int viewY, double opacity)
{
	Cairo.cairo_set_source_surface(viewVars.cr, viewVarsSrc.surface, x - viewX, y - viewY);
	double x1,y1,x2,y2;
	x1 = x;
	y1 = y;
	x2 = view.width() - viewX;
	y2 = view.height() - viewY;
	Cairo.cairo_save(viewVars.cr);
	Cairo.cairo_rectangle(viewVars.cr, x1, y1, x2, y2);
	Cairo.cairo_clip(viewVars.cr);
	Cairo.cairo_paint_with_alpha(viewVars.cr, opacity);
	Cairo.cairo_restore(viewVars.cr);
}

void drawView(ref ViewPlatformVars* viewVars, ref View view, int x, int y, ref ViewPlatformVars* viewVarsSrc, ref View srcView, int viewX, int viewY, int viewWidth, int viewHeight, double opacity)
{
	Cairo.cairo_set_source_surface(viewVars.cr, viewVarsSrc.surface, x - viewX, y - viewY);
	double x1,y1,x2,y2;
	x1 = x;
	y1 = y;
	x2 = viewWidth;
	y2 = viewHeight;
	Cairo.cairo_save(viewVars.cr);
	Cairo.cairo_rectangle(viewVars.cr, x1, y1, x2, y2);
	Cairo.cairo_clip(viewVars.cr);
	Cairo.cairo_paint_with_alpha(viewVars.cr, opacity);
	Cairo.cairo_restore(viewVars.cr);
}

void fillRegion(ViewPlatformVars* viewVars, RegionPlatformVars* rgnVars, bool rgnPlatformDirty, Region rgn, int x, int y) {
}

void strokeRegion(ViewPlatformVars* viewVars, RegionPlatformVars* rgnVars, bool rgnPlatformDirty, Region rgn, int x, int y) {
}

void drawRegion(ViewPlatformVars* viewVars, RegionPlatformVars* rgnVars, bool rgnPlatformDirty, Region rgn, int x, int y) {
}

void clipSave(ViewPlatformVars* viewVars)
{
}

void clipRestore(ViewPlatformVars* viewVars)
{
}

void clipRect(ViewPlatformVars* viewVars, int x, int y, int x2, int y2)
{
}

void clipRegion(ViewPlatformVars* viewVars, Region region)
{
}