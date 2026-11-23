import FamilyCore
import SwiftUI

func gameTypeLabel(_ type: GameType) -> String {
  switch type {
  case .sevenWonders: L("gameTypeSevenWonders")
  case .other: L("gameTypeOther")
  }
}

func wonderLabel(_ category: WonderCategory) -> String {
  switch category {
  case .maravilla: L("categoryWonder")
  case .monedas: L("categoryCoins")
  case .rojo: L("categoryRed")
  case .azul: L("categoryBlue")
  case .amarillo: L("categoryYellow")
  case .verde: L("categoryGreen")
  case .morado: L("categoryPurple")
  }
}

func wonderColor(_ category: WonderCategory) -> Color {
  switch category {
  case .maravilla: Color(red: 0x8D / 255, green: 0x6E / 255, blue: 0x63 / 255)
  case .monedas: Color(red: 0xC4 / 255, green: 0xA1 / 255, blue: 0x5A / 255)
  case .rojo: Color(red: 0xC4 / 255, green: 0x45 / 255, blue: 0x36 / 255)
  case .azul: Color(red: 0x3D / 255, green: 0x6F / 255, blue: 0x9C / 255)
  case .amarillo: Color(red: 0xC4 / 255, green: 0x92 / 255, blue: 0x12 / 255)
  case .verde: Color(red: 0x3E / 255, green: 0x7C / 255, blue: 0x59 / 255)
  case .morado: Color(red: 0x6E / 255, green: 0x4B / 255, blue: 0x8A / 255)
  }
}

/// Line colors for the win chart: one per player, in order.
func winLineColors(dark: Bool) -> [Color] {
  let light: [UInt32] = [0x7A3142, 0x2A6F4E, 0x315F8C, 0xC47B2B, 0x6B4C9A, 0xB5524A, 0x3E7C8A, 0x8A5A2B]
  let night: [UInt32] = [0xE7A0AE, 0x7DCEA0, 0x8EB4E0, 0xE2B15A, 0xC4A6E8, 0xF0A197, 0x8FD0D6, 0xE0B48A]
  return (dark ? night : light).map {
    Color(red: Double($0 >> 16 & 0xFF) / 255, green: Double($0 >> 8 & 0xFF) / 255, blue: Double($0 & 0xFF) / 255)
  }
}

/// `ana@mail.com` -> `ana`
func shortName(_ email: String) -> String {
  email.split(separator: "@").first.map(String.init) ?? email
}

struct TypeChip: View {
  let type: GameType

  var body: some View {
    Text(gameTypeLabel(type))
      .font(.caption.weight(.bold))
      .padding(.horizontal, 10).padding(.vertical, 5)
      .background(type == .sevenWonders ? Color.accentColor.opacity(0.18) : Color.secondary.opacity(0.18), in: .capsule)
      .foregroundStyle(type == .sevenWonders ? Color.accentColor : Color.secondary)
  }
}
