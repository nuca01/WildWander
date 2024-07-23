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
    
    private var currentYear: String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let currentYear = dateFormatter.string(from: date)
        return currentYear
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
                .frame(maxHeight: 50)
            
            profileIcon
            
            nameText
            
            Divider()
                .frame(height: 3)
                .background(.black.opacity(0.1))
            
            Spacer()
                .frame(maxHeight: 30)
            
            statsVStack
            
            logoutButton
            
            Spacer()
        }
        .padding(.horizontal)
        .foregroundStyle(darkGreen)
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
        Text("\(viewModel.userDetails?.firstName ?? "") \(viewModel.userDetails?.lastName ?? "unavailable") ")
            .font(.system(size: 32, weight: .semibold))
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
                value: viewModel.userDetails?.completedLength ?? 0,
                title: "Kilometres"
            )
            
            Spacer()
        }
        .frame(maxHeight: 100)
        .padding(.horizontal)
    }
    
    private var statsVStack: some View {
        VStack(alignment: .leading) {
            Text("\(currentYear) Stats")
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
                .font(.system(size: 60, weight: .bold))
            
            Text(title)
                .foregroundStyle(wildWanderGreen)
        }
    }
}

#Preview {
    ProfilePageView(viewModel: ProfilePageViewModel())
}
