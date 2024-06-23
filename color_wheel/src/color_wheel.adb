pragma Ada_2022;
with Ada.Numerics;                      use Ada.Numerics;
with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;
with Ada.Text_IO;                       use Ada.Text_IO;
procedure Color_Wheel is
   type Colour_Component is mod 2 ** 8;
   type RGB is record
      R, G, B : Colour_Component;
   end record;
   type Grid_2D is array (Integer range <>, Integer range <>) of RGB;

   Diameter  : constant Integer := 480;
   Radius    : constant Integer := Diameter / 2;
   Radius_Fl : constant Float   := Float (Radius);
   Image     : Grid_2D (-Radius .. Radius, -Radius .. Radius);
   V         : constant Float   := 1.0;

   procedure Write_PPM (Grid : Grid_2D; Filename : String) is
      PPM_File : File_Type;
   begin
      Create (PPM_File, Out_File, Filename);
      Put_Line (PPM_File, "P3");
      Put_Line (PPM_File, Grid'Length (1)'Image & Grid'Length (2)'Image);
      Put_Line (PPM_File, "255");
      for Y in -Radius .. Radius loop
         for X in -Radius .. Radius loop
            Put_Line (PPM_File, Grid (X, Y).R'Image & Grid (X, Y).G'Image & Grid (X, Y).B'Image);
         end loop;
      end loop;
      Close (PPM_File);
   end Write_PPM;

   function Atan2 (Y, X : Float) return Float is
      Res : Float;
   begin
      if X > 0.0 then
         Res := Arctan (Y / X);
      elsif X < 0.0 and then Y >= 0.0 then
         Res := Arctan (Y / X) + Pi;
      elsif X < 0.0 and then Y < 0.0 then
         Res := Arctan (Y / X) - Pi;
      elsif X = 0.0 and then Y > 0.0 then
         Res := Pi / 2.0;
      elsif X = 0.0 and then Y > 0.0 then
         Res := -Pi / 2.0;
      else
         Res := -Pi / 2.0;  --  Technically: Undefined
      end if;
      return Res;
   end Atan2;
begin
   for Y in -Radius .. Radius loop
      for X in -Radius .. Radius loop
         declare
            XX : Float := Float (X);
            YY : Float := Float (Y);
            Dist : Float := Sqrt (XX ** 2 + YY ** 2);
            HI, HF, P, Q, T : Float;
            Point : RGB;
         begin
            if Dist <= Radius_Fl then
               declare
                  Sat  : Float := Dist / Radius_Fl;
                  Hue  : Float := Atan2 (YY, XX);
                  RR, GG, BB : Float;
               begin
                  if Hue < 0.0 then Hue := Hue + 2.0 * Pi; end if;
                  Hue := (Hue * 180.0 / Pi) / 60.0;
                  HI := Float'Floor (Hue);
                  HF := Hue - HI;
                  P := 1.0 - Sat;
                  Q := 1.0 - Sat * HF;
                  T := 1.0 - Sat * (1.0 - HF);
                  case Integer (HI) is
                     when 0 => RR := V; GG := T; BB := P;
                     when 1 => RR := Q; GG := V; BB := P;
                     when 2 => RR := P; GG := V; BB := T;
                     when 3 => RR := P; GG := Q; BB := V;
                     when 4 => RR := T; GG := P; BB := V;
                     when 5 => RR := V; GG := P; BB := Q;
                     when others => null;
                  end case;
                  Point.R := Colour_Component (Integer (Float'Floor (RR * 255.0)));
                  Point.G := Colour_Component (Integer (Float'Floor (GG * 255.0)));
                  Point.B := Colour_Component (Integer (Float'Floor (BB * 255.0)));
                  Image (X, Y) := Point;
               end;
            end if;
         end;
      end loop;
   end loop;
   Write_PPM (Image, "color_wheel.ppm");
end Color_Wheel;
