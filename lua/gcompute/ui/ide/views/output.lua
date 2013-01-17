local self = GCompute.IDE.ViewTypes:CreateType ("Output")

function self:ctor (container)
	self:SetTitle ("Output")
	self:SetIcon ("icon16/application_xp_terminal.png")
	
	self.CodeEditor = vgui.Create ("GComputeCodeEditor", container)
	self.CodeEditor:GetDocument ():AddView (self)
	self.CodeEditor:SetCompilationEnabled (false)
	self.CodeEditor:SetLineNumbersVisible (false)
	self.CodeEditor:SetReadOnly (true)
	
	self.CodeEditor:AddEventListener ("DoubleClick",
		function (_, x, y)
			local lineColumnLocation = self.CodeEditor:PointToLocation (x, y)
			local line = self.CodeEditor:GetDocument ():GetLine (lineColumnLocation:GetLine ())
			if not line then return end
			local lineText = line:GetText ()
			local sourceDocumentId = line:GetAttribute ("SourceDocumentId", 0)
			local sourceDocumentPath = line:GetAttribute ("SourceDocumentPath", 0)
			
			-- Attempt to get line, char information
			-- line %d, char %d
			
			local lowercaseLineText = lineText:lower ()
			local pathMatch = nil
			local lineMatch, charMatch = lowercaseLineText:match ("line[ \t]*([0-9]+),?[ \t]*char[ \t]*([0-9]+)")
			if not lineMatch then
				lineMatch, charMatch = lowercaseLineText:match ("line[ \t]*([0-9]+),?[ \t]*character[ \t]*([0-9]+)")
			end
			if not lineMatch then
				lineMatch = lowercaseLineText:match ("line[ \t]*([0-9]+)")
			end
			if not lineMatch then
				-- debug.Trace style stack trace
				pathMatch, lineMatch = lowercaseLineText:match ("lua/(.*):([0-9]+): ")
			end
			if not lineMatch then
				-- GLib style stack trace
				pathMatch, lineMatch = lowercaseLineText:match ("lua/(.*): ([0-9]+)%)")
			end
			if not lineMatch then
				lineMatch = lowercaseLineText:match (":([0-9]+): ")
			end
			
			local line = tonumber (lineMatch)
			local char = tonumber (charMatch)
			if not line then return end
			
			if pathMatch then
				sourceDocumentId = nil
				sourceDocumentPath = "luacl/" .. pathMatch
			end
			
			local document = self:GetDocumentManager ():GetDocumentById (sourceDocumentId)
			local view = nil
			if not document then
				document = self:GetDocumentManager ():GetDocumentByPath (sourceDocumentPath)
			end
			if not document and sourceDocumentPath and sourceDocumentPath ~= nil then
				local editorFrame = self:GetContainer ():GetDockContainer ():GetRootDockContainer ():GetParent ()
				editorFrame:OpenPath (sourceDocumentPath,
					function (success, file, view)
						self:BringUpView (view, line, char)
					end
				)
				return
			elseif document then
				view = document:GetView (1)
			end
			
			if not view then return end
			self:BringUpView (view, line, char)
		end
	)
	
	self.ClipboardTarget = GCompute.CodeEditor.EditorClipboardTarget (self.CodeEditor)
	
	-- Buffering
	self.BufferText         = {}
	self.BufferColor        = nil
	self.BufferDocumentId   = nil
	self.BufferDocumentPath = nil
end

function self:Append (text, color, sourceDocumentId, sourceDocumentPath)
	if not text then return end
	
	if self.BufferDocumentId ~= sourceDocumentId or
	   self.BufferDocumentPath ~= sourceDocumentPath or
	   not self:ColorEquals (self.BufferColor, color) then
		self:Flush ()
		
		self.BufferColor        = color
		self.BufferDocumentId   = sourceDocumentId
		self.BufferDocumentPath = sourceDocumentPath
	end
	
	self.BufferText [#self.BufferText + 1] = text
end

function self:Clear ()
	self:Flush ()
	self:GetEditor ():Clear ()
end

function self:Flush ()
	if #self.BufferText > 0 then
		local codeEditor = self:GetEditor ()
		local document = codeEditor:GetDocument ()
		local startPos = document:GetEnd ()
		codeEditor:Append (table.concat (self.BufferText))
		local endPos = document:GetEnd ()
		if self.BufferColor then
			document:SetColor (self.BufferColor, startPos, endPos)
		end
		document:SetAttribute ("SourceDocumentId", self.BufferDocumentId, startPos, endPos)
		document:SetAttribute ("SourceDocumentPath", self.BufferDocumentPath, startPos, endPos)
	end
	
	self.BufferText         = {}
	self.BufferColor        = nil
	self.BufferDocumentId   = nil
	self.BufferDocumentPath = nil
end

function self:GetEditor ()
	return self.CodeEditor
end

-- Components
function self:GetClipboardTarget ()
	return self.ClipboardTarget
end

-- Internal, do not call
function self:BringUpView (view, line, char)
	if not view then return end
	view:Select ()
	
	if view:GetType () ~= "Code" then return end
	
	local location = GCompute.CodeEditor.LineCharacterLocation (line - 1, char and (char - 1) or 0)
	location = view:GetEditor ():GetDocument ():CharacterToColumn (location, view:GetEditor ():GetTextRenderer ())
	view:GetEditor ():SetCaretPos (location)
	view:GetEditor ():SetSelection (view:GetEditor ():GetCaretPos ())
end

function self:ColorEquals (a, b)
	if a == nil and b == nil then return true end
	if     a and not b then return false end
	if not a and     b then return false end
	if a.r ~= b.r then return false end
	if a.g ~= b.g then return false end
	if a.b ~= b.b then return false end
	if a.a ~= b.a then return false end
	return true
end

-- Event handlers
function self:Think ()
	self:Flush ()
end