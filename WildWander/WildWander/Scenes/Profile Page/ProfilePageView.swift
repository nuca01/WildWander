//
//  ProfilePageView.swift
//  WildWander
//
//  Created by nuca on 22.07.24.
//

import SwiftUI

struct ProfilePageView: View {
    //MARK: - Properties
    @ObservedObject private var viewModel: ProfilePageViewModel
    private var darkGreen = Color(uiColor: .darkGreen)
    private var wildWanderGreen = Color(uiColor: .wildWanderGreen)
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Spacer()
                    .frame(height: 50)
                
                profileIcon
                
                nameText
                
                Spacer()
                    .frame(height: 10)
                
                ageText
                
                Spacer()
                    .frame(height: 25)
                
                Divider()
                    .frame(height: 3)
                    .background(.black.opacity(0.1))
                
                Spacer()
                    .frame(height: 25)
                
                statsVStack
                
                
                
                Spacer()
                
                logoutButton
            }
            .padding(.horizontal)
            .foregroundStyle(darkGreen)
        }
        .frame(maxHeight: .infinity)
        .refreshable {
            viewModel.getUserInformation()
        }
    }
    
    private var profileIcon: some View {
        Image(viewModel.userDetails?.gender == 1 ? "maleHiker": "femaleHiker")
            .resizable()
            .renderingMode(.template)
            .aspectRatio(contentMode: .fill)
            .frame(width: 100, height: 100)
            .scaleEffect(CGSize(size: 1.08))
            .clipShape(Circle())
            .overlay(
                Circle().stroke(Color.wildWanderGreen, lineWidth: 0.5)
            )
    }
    
    private var nameText: some View {
        Text("\(viewModel.userDetails?.firstName ?? "") \(viewModel.userDetails?.lastName ?? "fddd") ")
            .font(.system(size: 36, weight: .semibold))
    }
    
    private var ageText: some View {
        Text("Age: \(viewModel.getAge() ?? 0) years old")
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(.gray)
    }
    
    private var statsHStack: some View {
        HStack {
            activityInformationVStack(
                value: viewModel.userDetails?.completedTrailCount ?? 0,
                title: "Activities"
            )
            
            Spacer()
            
            Divider()
            
            Spacer()
                .frame(maxWidth: 40)
            activityInformationVStack(
                value: viewModel.userDetailsLengthInKilometres(),
                title: "Kilometres"
            )
            
            Spacer()
        }
        .frame(maxHeight: 100)
        .padding(.horizontal)
    }
    
    private var statsVStack: some View {
        VStack(alignment: .leading) {
            Text("\(viewModel.currentYear) Stats")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(wildWanderGreen)
            
            statsHStack
        }
        .padding(.vertical, 2)
        .padding(14)
        .background(darkGreen.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 25.0))
    }
    
    private var logoutButton: some View {
        Button("log out") {
            viewModel.logOut()
        }
        .frame(maxWidth: .infinity)
        .foregroundStyle(.red)
        .font(.system(size: 15, weight: .bold))
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .padding()
        .background(.red.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 25))
    }
    
    //MARK: - Initializer
    init(viewModel: ProfilePageViewModel) {
        self.viewModel = viewModel
    }
    
    //MARK: - Method
    private func activityInformationVStack(value: Int, title: String) -> some View {
        VStack(alignment: .leading) {
            Text("\(value)")
                .font(.system(size: 50, weight: .bold))
            
            Text(title)
                .foregroundStyle(wildWanderGreen)
        }
    }
}

#Preview {
    ProfilePageView(viewModel: ProfilePageViewModel())
}
