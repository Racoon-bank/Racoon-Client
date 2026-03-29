//
//  ProfileViewModel.swift
//  Racoon-client
//
//  Created by dark type on 27.02.2026.
//


import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published private(set) var state: AsyncViewState = .idle
    @Published private(set) var username: String = ""
    @Published private(set) var email: String = ""
    
    
    @Published var currentTheme: AppThemePreference = .light

    private let getProfile: GetProfileUseCase
    private let logout: LogoutUseCase
    private let setTheme: SetThemeUseCase
    private let appSettingsStorage: AppSettingsStorage
    private unowned let appState: AppState

    init(
        getProfile: GetProfileUseCase,
        logout: LogoutUseCase,
        setTheme: SetThemeUseCase,
        appSettingsStorage: AppSettingsStorage,
        appState: AppState
    ) {
        self.getProfile = getProfile
        self.logout = logout
        self.setTheme = setTheme
        self.appSettingsStorage = appSettingsStorage
        self.appState = appState
        
        self.currentTheme = appSettingsStorage.load().theme
    }

    func load() async {
        state = .loading
        do {
            let profile = try await getProfile()
            username = profile.username
            email = profile.email
            state = .idle
        } catch {
            state = .error(message: "Failed to load profile.")
        }
    }
    
    func toggleTheme(isDark: Bool) async {
        let newTheme: AppThemePreference = isDark ? .dark : .light
        
        self.currentTheme = newTheme
        
        do {
            try await setTheme(newTheme)
        } catch {
            self.currentTheme = isDark ? .light : .dark
            state = .error(message: "Failed to sync theme with server.")
        }
    }

    func signOut() async {
        state = .loading
        do {
            try await logout()
            state = .idle
            appState.onLoggedOut()
        } catch {
            state = .error(message: "Failed to sign out.")
        }
    }

    func clearError() {
        if case .error = state { state = .idle }
    }
}
