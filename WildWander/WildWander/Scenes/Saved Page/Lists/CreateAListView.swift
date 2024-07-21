//
//  CreateAListView.swift
//  WildWander
//
//  Created by nuca on 21.07.24.
//

import SwiftUI

struct CreateAListView: View {
    //MARK: - Properties
    @State private var name: String = ""
    @State private var description: String = ""
    @FocusState private var isFocused
    
    var didTapSave: ((_: String, _: String) -> Void)
    
    var body: some View {
        ZStack {
            background
            
            VStack {
                Spacer()
                    .frame(maxHeight: 50)
                
                VStack(alignment: .leading, spacing: 20) {
                    createAListTitle
                    
                    vStack(
                        title: "List name",
                        bindingText: $name,
                        placeholder: "Ex: Top hikes in Tbilisi",
                        height: 65,
                        required: true
                    )
                    
                    vStack(
                        title: "Description",
                        bindingText: $description,
                        placeholder: "Add list description",
                        height: 100
                    )
                    
                    Spacer()
                    
                    saveButton
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var background: some View {
        Color.white
            .onTapGesture {
                isFocused = false
            }
    }
    
    private var createAListTitle: some View {
        Text("Create a list")
            .font(.system(size: 30, weight: .semibold))
            .padding(.bottom, 10)
    }
    
    private var requiredText: some View {
        Text("this field is required")
            .foregroundStyle(.red)
            .font(.system(size: 14))
    }
    
    private var saveButton: some View {
        Button("Save") {
            didTapSave(name, description)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(Color.init(uiColor: .wildWanderGreen))
        .clipShape(RoundedRectangle(cornerRadius: 25))
    }
    
    //MARK: - Methods
    private func vStack(
        title: String,
        bindingText: Binding<String>,
        placeholder: String,
        height: CGFloat,
        required: Bool = false
    ) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .fontWeight(.light)
            textEditor(
                bindingText: bindingText,
                placeholder: placeholder,
                height: height,
                required: required
            )
        }
    }
    
    private func textEditor(
        bindingText: Binding<String>,
        placeholder: String,
        height: CGFloat,
        required: Bool = false
    ) -> some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .leading) {
                if bindingText.wrappedValue.isEmpty {
                    placeholderView(placeholder)
                }
                
                textEditor(bindingText: bindingText, required: required)
            }
            .frame(height: height)
            .overlay(
                border(bindingText: bindingText, required: required)
            )
            
            if required && bindingText.wrappedValue.isEmpty {
                requiredText
            }
        }
    }
    
    private func placeholderView(_ text: String) -> some View {
        VStack {
            Text(text)
                .padding(.top, 10)
                .padding(.leading, 6)
                .padding(12)
            Spacer()
        }
    }
    
    private func textEditor( 
        bindingText: Binding<String>,
        required: Bool
    ) -> some View {
        VStack {
            TextEditor(text: bindingText)
                .padding(12)
                .opacity(bindingText.wrappedValue.isEmpty ? 0.75 : 1)
                .focused($isFocused)
                .onReceive(bindingText.wrappedValue.publisher.last()) {
                    if required && ($0 as Character).asciiValue == 10 {
                        isFocused = false
                        bindingText.wrappedValue.removeLast()
                    }
                }
            Spacer()
        }
    }
    
    private func border(
        bindingText: Binding<String>,
        required: Bool
    ) -> some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(
                required && bindingText.wrappedValue.isEmpty ? Color.red: Color.gray,
                lineWidth: 1
            )
    }
}
