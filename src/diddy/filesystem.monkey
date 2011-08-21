Strict
Import mojo

Class FileSystem Extends DataConversion
Private
	Field _header:String = "MKYDATA"
	Field fileData:String
	Field index:StringMap<FileStream>
Public
	
	Method New()
		Self.LoadAll()
	End
	
	Method WriteFile:FileStream(filename:String)
		Local f:FileStream = new FileStream
		f.filename = filename
		f.fileptr = 0
		Self.index.Set(f.filename.ToLower(),f)
		Return f	
	End
	
	Method ReadFile:FileStream(filename:String)
		filename = filename.ToLower()
		Local f:FileStream
		f = Self.index.ValueForKey(filename)
		f.fileptr = 0
		Return f
	End
	
	Method FileExists:Bool(filename:String)
		filename = filename.ToLower()
		if Self.index.Contains(filename)
			Return True
		Else
			Return False
		End
	End
	
	Method ListDir:Void()
		Local filename:String
		Local stream:FileStream
		Print "Directory Listing:"
		For filename = EachIn Self.index.Keys()
			stream = Self.index.ValueForKey(filename)
			Print filename + "   " + stream.data.Length()+" byte(s)."
		Next
	End
	
	Method DeleteFile:Void(filename:String)
		filename = filename.ToLower()
		if Self.index.Contains(filename)
			Self.index.Remove(filename)
		End
	End
	
	Method SaveAll:Void()
		Local f:FileStream
		Self.fileData = Self._header'header
		self.fileData+= Self.IntToString(Self.index.Count())'number of files in index
		if Self.index.Count() > 0
			For f = EachIn Self.index.Values()
				'store filename
				Self.fileData+= Self.IntToString(f.filename.Length())
				if f.filename.Length() > 0
					Self.fileData+= f.filename
				End
				'store data
				Self.fileData+= Self.IntToString(f.data.Length())
				if f.data.Length() > 0
					Self.fileData+= f.data
				End
			Next
		End
		SaveState(Self.fileData)
	End
	
	Method LoadAll:Void()
		Local numFiles:Int
		Local stream:FileStream
		Local len:Int
		Local ptr:Int
		Self.fileData = LoadState()
		self.index = New StringMap<FileStream>
		if Self.fileData.Length() > 0
			if Self.fileData.StartsWith(Self._header)
				Self.index.Clear()
				ptr+=Self._header.Length()
				numFiles = Self.StringToInt(Self.fileData[ptr..ptr+4])
				ptr+=4
				if numFiles > 0
					For Local n:Int = 1 to numFiles
						stream = New FileStream
						'filename
						len = Self.StringToInt(Self.fileData[ptr..ptr+4])
						ptr+=4
						if len > 0
							stream.filename = Self.fileData[ptr..ptr+len]
							ptr+=len
						End
						'data
						len = Self.StringToInt(Self.fileData[ptr..ptr+4])
						ptr+=4
						if len > 0
							stream.data = Self.fileData[ptr..ptr+len]
							ptr+=len
						End
						Self.index.Set(stream.filename,stream)
					Next
				End
			End
		Else
			SaveState(Self._header+Self.IntToString(0))'save empty file and indicate no files stored
		End
	End
End



Class FileStream Extends DataConversion
	Field filename:String
	Field fileptr:Int
Private
	Field data:String
Public
	
	Method ReadInt:Int()
		Local result:string
		result = Self.data[Self.fileptr..self.fileptr+4]
		Self.fileptr+=4
		Return Self.StringToInt(result)
	End
	
	Method WriteInt:Void(val:Int)
		Self.data+=Self.IntToString(val)
	End
	
	Method ReadString:String()
		Local result:String
		Local strLen:Int = self.StringToInt(self.data[self.fileptr..self.fileptr+4])
		Self.fileptr+=4
		if strLen > 0
			result = Self.data[Self.fileptr..self.fileptr+strLen]
			Self.fileptr+=strLen
			Return result
		End
	End
	
	Method WriteString:Void(val:String)
		Self.data+=Self.IntToString(val.Length())
		if val.Length() > 0
			Self.data+=val
		End
	End
	
	Method ReadFloat:Float()
		Local result:float
		Local s:String
		Local strLen:Int = self.StringToInt(self.data[self.fileptr..self.fileptr+4])
		Self.fileptr+=4
		s = Self.data[Self.fileptr..self.fileptr+strLen]
		result = Self.StringToFloat(s)
		Self.fileptr+=strLen
		Return result
	End
	
	Method WriteFloat:Void(val:Float)
		Local s:String = self.FloatToString(val)
		Self.data+=Self.IntToString(s.Length())
		Self.data+=s
	End
End

Class DataConversion
	Method IntToString:String(val:Int)
		Local result:String
		result = String.FromChar((val Shr 24) & $FF)
		result+= String.FromChar((val Shr 16) & $FF)
		result+= String.FromChar((val Shr 8) & $FF)
		result+= String.FromChar(val & $FF)
		Return result
	End

	Method FloatToString:String(val:Float)
		Return String(val)
	End		
	
	Method StringToInt:Int(val:String)
		Local result:Int
		result = (val[0] Shl 24)
		result|= (val[1] Shl 16)
		result|= (val[2] Shl 8)
		result|= val[3]
		Return result
	End

	Method StringToFloat:Float(val:String)
		Return Float(val)
	End		
End