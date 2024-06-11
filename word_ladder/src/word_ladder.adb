pragma Ada_2022;
with Ada.Containers.Vectors;
with Ada.Strings.Unbounded;     use Ada.Strings.Unbounded;
with Ada.Text_IO;               use Ada.Text_IO;
with Ada.Text_IO.Unbounded_IO;  use Ada.Text_IO.Unbounded_IO;
procedure Word_Ladder is

   DICT_FILENAME : constant String   := "unixdict.txt";
   MAX_DEPTH     : constant Positive := 50;

   subtype LC_Chars is Character range 'a' .. 'z';

   type Word_Rec_T is record
      Parent, Word : Unbounded_String;
   end record;

   package Word_Vectors is new Ada.Containers.Vectors (Positive, Unbounded_String);
   package Used_Vectors is new Ada.Containers.Vectors (Positive, Boolean);
   package Mutation_Vectors is new Ada.Containers.Vectors (Positive, Word_Rec_T);
   type Mutation_Arr is array (1 .. MAX_DEPTH) of Mutation_Vectors.Vector;

   function Load_Candidate_Words (Dict_Filename : String; Word_Len : Positive)
            return Word_Vectors.Vector is
      Dict_File : File_Type;
      Read_Word : Unbounded_String;
      Cands     : Word_Vectors.Vector;
      Valid     : Boolean;
      C         : Character;
   begin
      Open (File => Dict_File, Mode => In_File, Name => Dict_Filename);
      while not End_Of_File (Dict_File) loop
         Read_Word := Get_Line (Dict_File);
         if Length (Read_Word) = Word_Len then
            Valid := True;
            for Ix in 1 .. Word_Len loop
               C := Element (Read_Word, Ix);
               Valid := C in LC_Chars;
               exit when not Valid;
            end loop;
            if Valid then Cands.Append (Read_Word); end if;
         end if;
      end loop;
      Close (Dict_File);
      return Cands;
   end Load_Candidate_Words;

   function Create_Unused_Vec (Vec_Len : Positive)
            return Used_Vectors.Vector is
      Used : Used_Vectors.Vector;
   begin
      for i in 1 .. Vec_Len loop
         Used.Append (False);
      end loop;
      return Used;
   end Create_Unused_Vec;

   function Mutate (Word : Unbounded_String; Len : Positive; Dict : Word_Vectors.Vector)
            return Word_Vectors.Vector is
      Mutations : Word_Vectors.Vector;
      Poss_Word : Unbounded_String;
   begin
      for Ix in 1 .. Len loop
         for Letter in LC_Chars loop
            if Letter /= Element (Word, Ix) then
               Poss_Word := Word;
               Replace_Element (Poss_Word, Ix, Letter);
               if Dict.Contains (Poss_Word) then
                  Mutations.Append (Poss_Word);
               end if;
            end if;
         end loop;
      end loop;
      return Mutations;
   end Mutate;

   procedure Ladder (Start_S, Target_S : String) is
      Dictionary : Word_Vectors.Vector;
      Used       : Used_Vectors.Vector;
      Word_Tree  : Mutation_Arr;
      Level      : Positive := 1;
      Mutations  : Word_Vectors.Vector;
      Muts_Vec   : Mutation_Vectors.Vector;
      Word_Rec   : Word_Rec_T;
      Found      : Boolean := False;
      Start, Target, Word : Unbounded_String;

      procedure Check_Mutations is
         Ix         : Positive;
      begin
         for Word of Mutations loop
            Ix := Word_Vectors.Find_Index (Dictionary, Word);
            if not Used (Ix) then
               Used (Ix) := True;
               Word_Rec.Word := Word;
               Muts_Vec.Append (Word_Rec);
            end if;
            if Word = Target then
               Found := True;
               return;
            end if;
         end loop;
      end Check_Mutations;
   begin
      if Start_S'Length /= Target_S'Length then
         Put_Line ("ERROR: Start and Target words must be same length.");
         return;
      end if;
      Dictionary := Load_Candidate_Words (DICT_FILENAME, Start_S'Length);
      Used       := Create_Unused_Vec (Positive (Word_Vectors.Length (Dictionary)));
      Start      := To_Unbounded_String (Start_S);
      Target     := To_Unbounded_String (Target_S);
      while Level <= MAX_DEPTH and then not Found loop
         Muts_Vec.Clear;
         if Level = 1 then
            Mutations := Mutate (Start, Start_S'Length, Dictionary);
            Word_Rec.Parent := Start;
            Check_Mutations;
         else
            for Parent_Rec of Word_Tree (Level - 1) loop
               Mutations := Mutate (Parent_Rec.Word, Start_S'Length, Dictionary);
               Word_Rec.Parent := Parent_Rec.Word;
               Check_Mutations;
            end loop;
         end if;
         Word_Tree (Level) := Muts_Vec;
         Level := @ + 1;
      end loop;
      if not Found then
         Put_Line (Start & " -> " & Target & " - No solution found at depth" & MAX_DEPTH'Image);
      else
         Word := Target;
         for Lev in reverse 1 .. Level - 1 loop
            for W_Ix in 1 .. Word_Tree (Lev).Length loop
               Word_Rec := Word_Tree (Lev)(Positive (W_Ix));
               if Word_Rec.Word = Word then
                  Put (Word & " <- ");
                  Word := Word_Rec.Parent;
                  exit;
               end if;
            end loop;
         end loop;
         Put (Start); New_Line;
      end if;
   end Ladder;
begin
   Ladder ("boy", "man");
   Ladder ("girl", "lady");
   Ladder ("jane", "john");
   Ladder ("child", "adult");
   Ladder ("ada", "god");
   Ladder ("rust", "hell");
end Word_Ladder;
