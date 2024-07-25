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
                    .frame(height: 25)
                
                completedTrails
                
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
        Text("Age: \(viewModel.userDetails?.age ?? 0) years old")
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
    
    private var completedTrails: some View {
        VStack(alignment: .leading, spacing: 2) {
            VStack(alignment: .leading) {
                Text("Completed Trails")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.black)
                
                Divider()
                    .frame(maxWidth: 162)
                    .frame(height: 2)
                    .background(.black)
            }
            
            Divider()
                .frame(height: 2)
                .background(.black.opacity(0.1))
            
            Spacer()
                .frame(height: 10)
            
            completedTrailsLazyVStack
        }
    }
    
    private var completedTrailsLazyVStack: some View {
        LazyVStack(alignment: .leading) {
            ForEach(viewModel.completedTrails ?? [/*CompletedTrail(id: 1, name: "name", trailId: nil, length: 848, elevationGain: 50, time: "23:55", date: "2024-07-24T22:50:51.578Z", staticImage: "https://upload.wikimedia.org/wikipedia/commons/8/89/Charles_Bond_Park_1.JPG")*/]) { completedTrail in
                HStack {
                    VStack(alignment: .leading) {
                        generateCompletedTrails(name: completedTrail.name ?? "")
                        
                        generateCompletedTrails(date: completedTrail.date ?? "")
                        
                        Text(completedTrail.trailId == nil ? "not published": "published")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(completedTrail.trailId == nil ? Color(red: 120 / 255, green: 0 / 255, blue: 30 / 255): Color(red: 88 / 255, green: 160 / 255, blue: 86 / 255))
                        
                        generateCompletedInformationHStack(with: completedTrail)
                    }
                    
                    Spacer()
                    
                    asyncImageWith(url: completedTrail.staticImage ?? "")
                }
                
                Divider()
            }
        }
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
    
    private func generateCompletedTrails(name: String) -> some View {
        Text(name)
            .font(.system(size: 19, weight: .semibold))
            .foregroundStyle(.black)
    }
    
    private func generateCompletedTrails(date: String) -> some View {
        Text(viewModel.formatDateInWords(date))
            .font(.system(size: 14))
            .foregroundStyle(.black.opacity(0.55))
    }
    
    private func generateCompletedInformationVStack(title: String, value: String) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .foregroundStyle(.black.opacity(0.55))
            Text(value)
                .font(.system(size: 13, weight: .semibold))
        }
    }

    private func generateCompletedInformationHStack(with completedTrail: CompletedTrail) -> some View {
        HStack(spacing: 15) {
            generateCompletedInformationVStack(title: "Length", value: viewModel.metresToKilometresInString(completedTrail.length ?? 0))
            
            hDivider()
            
            generateCompletedInformationVStack(title: "Elev. gain", value: "\(viewModel.metresToKilometresInString(completedTrail.elevationGain ?? 0))")
            
            hDivider()
            
            generateCompletedInformationVStack(title: "Time", value: completedTrail.time ?? "")
        }
    }
    
    private func hDivider() -> some View{
        Divider()
            .frame(width: 2)
            .background(.black.opacity(0.1))
    }
    
    private func asyncImageWith(url: String) -> some View {
        AsyncImage(url: viewModel.generateURL(from: url)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100)
                .clipShape(RoundedRectangle(cornerRadius: 10.0))
        } placeholder: {
            ProgressView()
        }
    }
}

#Preview {
    ProfilePageView(viewModel: ProfilePageViewModel())
}
