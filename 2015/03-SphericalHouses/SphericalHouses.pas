{ Perfectly Spherical Houses in a Vacuum 
  https://adventofcode.com/2015/day/3 
  
  Part 1
  Count the number of unique points on a grid visited while following a list
  of directions. 
  
  Part 2 
  Same as part 1 but directions alternate between two current points. }

Program SphericalHouses;

Const
  MoveRight = '>';
  MoveLeft = '<';
  MoveUp = '^';
  MoveDown = 'v';


Type 
  { Directions are stored in an array of strings. }
  TDirections = array Of string;
  TComparison = (LessThan, EqualTo, GreaterThan);
  { A point on a grid. }
  TPoint = Record
    x, y : integer;
  End;
  { A list of grid points. }
  TPointNodePtr = ^TPointNode;
  TPointNode = Record
    next : TPointNodePtr;
    point : TPoint;
  End;


{ Create a TPoint record. }
Function CreatePoint : TPoint;
Begin
  With CreatePoint Do
  Begin
    x := 0;
    y := 0;
  End;
End;


{ Compares two points and returns:
  LessThan    if point1 < point2
  EqualTo     if point1 == point2
  GreaterThan if point1 > point2 

  p1 < p2 if (p1.x < p2.x) or ((p1.x == p2.x) and (p1.y < p2.y) }
Function ComparePoints(point1, point2: TPoint) : TComparison;
Begin
  If point1.x < point2.x Then
    ComparePoints := LessThan
  Else If point1.x > point2.x Then
    ComparePoints := GreaterThan
  Else If point1.y < point2.y Then
    ComparePoints := LessThan
  Else If point1.y = point2.y Then
    ComparePoints := EqualTo
  Else
    ComparePoints := GreaterThan
End;


{ Create a new TPointNode for the given point. }
Function CreatePointNode(point : TPoint) : TPointNodePtr;
Begin
  New(CreatePointNode);
  CreatePointNode^.point := point;
  CreatePointNode^.next := Nil;
End;


{ Add a point to a list of visited points IFF the point is not already in the 
  list. Points are added in sorted order such that p1.x < p2.x. When p1.x = 
  p2.x, then p1.y < p2.y. }
Procedure AddVisitedPoint(point : TPoint; Var visitedList : TPointNodePtr);
Var 
  node, cursor : TPointNodePtr;
  comparison : TComparison;
  done : boolean;
Begin
  node := CreatePointNode(point);
  done := False;

  comparison := ComparePoints(point, visitedList^.point);
  If comparison = EqualTo Then
    { Don't add a point that's already in the list. }
    done := True
  Else If comparison = LessThan Then
    Begin
      { Add point to the beginning of the list. }
      node^.next := visitedList;
      visitedList := node;
      done := True;
    End;

  { Find where to add the point. }
  cursor := visitedList;
  While Not done And (cursor^.next <> Nil) Do
    Begin
      comparison := ComparePoints(point, cursor^.next^.point);
      If comparison = EqualTo Then
        { Don't add a point that's already in the list. }
        done := True
      Else If comparison = LessThan Then
        Begin
          { Add point and exit. }
          node^.next := cursor^.next;
          cursor^.next := node;
          done := True;
        End
      Else
        cursor := cursor^.next;
    End;

  If Not done Then
    Begin
      { Add point to end of list. }
      node^.next := cursor^.next;
      cursor^.next := node;
    End;
End;


{ Get the number of points in a list. }
Function GetPointCount(visitedList : TPointNodePtr) : integer;
Begin
  GetPointCount := 0;
  While visitedList <> Nil Do
    Begin
      visitedList := visitedList^.next;
      Inc(GetPointCount);
    End;
End;


{ Get list of directions.

  Classic Pascal limits the length of strings to 255 characters so we'll need 
  to return an array of strings. }
Function GetDirections() : TDirections;
Var 
  inputFile : TextFile;
  count : integer;
Begin
  Assign(inputFile, 'input.txt');
  Reset(inputFile);
  If IOResult <> 0 Then
    Begin
      WriteLn('ERROR: Unable to open file.');
      Exit;
    End;

  { Use a reasonable default for the size of the array we'll need. }
  SetLength(GetDirections, 50);
  count := 0;
  While Not Eof(inputFile) Do
    Begin
      Read(inputFile, GetDirections[count]);
      If IOResult <> 0 Then
        Begin
          WriteLn('ERROR: Unable to read file.');
          Close(inputFile);
          Exit;
        End;

      Inc(count);
      If count = Length(GetDirections) Then
        { Double the size of our array. }
        SetLength(GetDirections, Length(GetDirections) * 2);
    End;
  Close(inputFile);

  { Set the array size to the number of values actually read. }
  SetLength(GetDirections, count);
End;


{ Follow a list of directions on a grid and return the number of unique points
  visited. }
Function CountUniqueVisitedPoints(directions : TDirections; numVisitors : integer) : integer;
Var 
  current : array of TPoint;
  visitor : integer;
  visitedList : TPointNodePtr;
  nextDirections : string;
  dir : char;
  i : integer;
Begin
  SetLength(current, numVisitors);
  For i := 0 to numVisitors Do
    current[i] := CreatePoint;
  visitor := 0;
  visitedList := CreatePointNode(current[visitor]);
  For nextDirections In directions Do
    For dir In nextDirections Do
      Begin
        If dir = MoveRight Then
          Inc(current[visitor].x)
        Else If dir = MoveLeft Then
          Dec(current[visitor].x)
        Else If dir = MoveUp Then
          Inc(current[visitor].y)
        Else If dir = MoveDown Then
          Dec(current[visitor].y);
        AddVisitedPoint(current[visitor], visitedList);
        Inc(visitor);
        If visitor = numVisitors Then
          visitor := 0;
      End;
  CountUniqueVisitedPoints := GetPointCount(visitedList);
End;


Var 
  directions : TDirections;
  numUniqueVisitedPoints : integer;

Begin
  directions := GetDirections();
  numUniqueVisitedPoints := CountUniqueVisitedPoints(directions, 1);
  WriteLn('Part 1: ', numUniqueVisitedPoints);

  numUniqueVisitedPoints := CountUniqueVisitedPoints(directions, 2);
  WriteLn('Part 2: ', numUniqueVisitedPoints);
End.
