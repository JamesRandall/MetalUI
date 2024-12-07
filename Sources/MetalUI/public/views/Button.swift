//
//  Button.swift
//  starship-tactics
//
//  Created by James Randall on 03/12/2024.
//
/*
 struct Button : ContentView, BorderedView {
 let id = UUID()
 var position : simd_float2 = .zero
 var size : simd_float2 = .zero
 var backgroundColor : simd_float4 = simd_float4(1.0, 0.0, 0.0, 1.0)
 var attachedTo: UUID?
 var children: [View]
 var border = Border.none
 
 @ViewMetadata var metadata: LayoutMetadata = LayoutMetadata.empty()
 
 @Mutable var isPressed = false
 
 func build(builder: GuiViewBuilder) {
 if let attachedTo {
 builder.registerAttachment(attachingView: id, attachedTo: attachedTo)
 //if let attachedPosition = builder.getGameObjectPosition(id: attachedTo) {
 //    position = attachedPosition
 //}
 }
 }
 
 func update(builder: GuiMutater) {
 builder.rectangle(position: position, size: self.size, color: self.backgroundColor)
 border.draw(builder: builder, position: position, size: size)
 }
 }
 */
