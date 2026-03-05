import Foundation

// MARK: - Mock Data

extension CropDTO {
    static let mockData: [CropDTO] = [
        CropDTO(
            id: "1",
            name: "Maize",
            category: "Cereals",
            currentPrice: 950,
            unit: "kg",
            region: "Dar es Salaam",
            trend: "up",
            history: [
                PriceHistoryDTO(date: "2024-05-01", price: 820),
                PriceHistoryDTO(date: "2024-05-05", price: 850),
                PriceHistoryDTO(date: "2024-05-10", price: 870),
                PriceHistoryDTO(date: "2024-05-15", price: 900),
                PriceHistoryDTO(date: "2024-05-20", price: 920),
                PriceHistoryDTO(date: "2024-05-25", price: 940),
                PriceHistoryDTO(date: "2024-05-30", price: 950)
            ]
        ),
        CropDTO(
            id: "2",
            name: "Cashews",
            category: "Nuts",
            currentPrice: 2400,
            unit: "kg",
            region: "Mtwara",
            trend: "down",
            history: [
                PriceHistoryDTO(date: "2024-05-01", price: 2800),
                PriceHistoryDTO(date: "2024-05-05", price: 2750),
                PriceHistoryDTO(date: "2024-05-10", price: 2700),
                PriceHistoryDTO(date: "2024-05-15", price: 2600),
                PriceHistoryDTO(date: "2024-05-20", price: 2500),
                PriceHistoryDTO(date: "2024-05-25", price: 2450),
                PriceHistoryDTO(date: "2024-05-30", price: 2400)
            ]
        ),
        CropDTO(
            id: "3",
            name: "Coffee",
            category: "Nuts",
            currentPrice: 5200,
            unit: "kg",
            region: "Arusha",
            trend: "up",
            history: [
                PriceHistoryDTO(date: "2024-05-01", price: 4800),
                PriceHistoryDTO(date: "2024-05-05", price: 4900),
                PriceHistoryDTO(date: "2024-05-10", price: 5000),
                PriceHistoryDTO(date: "2024-05-15", price: 5100),
                PriceHistoryDTO(date: "2024-05-20", price: 5150),
                PriceHistoryDTO(date: "2024-05-25", price: 5180),
                PriceHistoryDTO(date: "2024-05-30", price: 5200)
            ]
        ),
        CropDTO(
            id: "4",
            name: "Rice",
            category: "Cereals",
            currentPrice: 1100,
            unit: "kg",
            region: "Mbeya",
            trend: "stable",
            history: [
                PriceHistoryDTO(date: "2024-05-01", price: 1080),
                PriceHistoryDTO(date: "2024-05-05", price: 1090),
                PriceHistoryDTO(date: "2024-05-10", price: 1100),
                PriceHistoryDTO(date: "2024-05-15", price: 1095),
                PriceHistoryDTO(date: "2024-05-20", price: 1105),
                PriceHistoryDTO(date: "2024-05-25", price: 1100),
                PriceHistoryDTO(date: "2024-05-30", price: 1100)
            ]
        ),
        CropDTO(
            id: "5",
            name: "Tomatoes",
            category: "Vegetables",
            currentPrice: 800,
            unit: "kg",
            region: "Dodoma",
            trend: "up",
            history: [
                PriceHistoryDTO(date: "2024-05-01", price: 500),
                PriceHistoryDTO(date: "2024-05-05", price: 560),
                PriceHistoryDTO(date: "2024-05-10", price: 620),
                PriceHistoryDTO(date: "2024-05-15", price: 680),
                PriceHistoryDTO(date: "2024-05-20", price: 720),
                PriceHistoryDTO(date: "2024-05-25", price: 770),
                PriceHistoryDTO(date: "2024-05-30", price: 800)
            ]
        ),
        CropDTO(
            id: "6",
            name: "Beans",
            category: "Legumes",
            currentPrice: 1800,
            unit: "kg",
            region: "Mwanza",
            trend: "down",
            history: [
                PriceHistoryDTO(date: "2024-05-01", price: 2200),
                PriceHistoryDTO(date: "2024-05-05", price: 2150),
                PriceHistoryDTO(date: "2024-05-10", price: 2100),
                PriceHistoryDTO(date: "2024-05-15", price: 2000),
                PriceHistoryDTO(date: "2024-05-20", price: 1950),
                PriceHistoryDTO(date: "2024-05-25", price: 1900),
                PriceHistoryDTO(date: "2024-05-30", price: 1800)
            ]
        ),
        CropDTO(
            id: "7",
            name: "Onions",
            category: "Vegetables",
            currentPrice: 600,
            unit: "kg",
            region: "Morogoro",
            trend: "stable",
            history: [
                PriceHistoryDTO(date: "2024-05-01", price: 580),
                PriceHistoryDTO(date: "2024-05-05", price: 590),
                PriceHistoryDTO(date: "2024-05-10", price: 600),
                PriceHistoryDTO(date: "2024-05-15", price: 610),
                PriceHistoryDTO(date: "2024-05-20", price: 605),
                PriceHistoryDTO(date: "2024-05-25", price: 600),
                PriceHistoryDTO(date: "2024-05-30", price: 600)
            ]
        ),
        CropDTO(
            id: "8",
            name: "Pineapple",
            category: "Fruits",
            currentPrice: 1200,
            unit: "kg",
            region: "Dar es Salaam",
            trend: "up",
            history: [
                PriceHistoryDTO(date: "2024-05-01", price: 900),
                PriceHistoryDTO(date: "2024-05-05", price: 950),
                PriceHistoryDTO(date: "2024-05-10", price: 1000),
                PriceHistoryDTO(date: "2024-05-15", price: 1050),
                PriceHistoryDTO(date: "2024-05-20", price: 1100),
                PriceHistoryDTO(date: "2024-05-25", price: 1150),
                PriceHistoryDTO(date: "2024-05-30", price: 1200)
            ]
        )
    ]
}
