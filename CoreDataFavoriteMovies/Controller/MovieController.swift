//
//  MovieController.swift
//  CoreDataFavoriteMovies
//
//  Created by Parker Rushton on 11/1/22.
//

import Foundation

class MovieController {
    static let shared = MovieController()
    
    private let apiController = MovieAPIController()
    private var viewContext = PersistenceController.shared.viewContext
    
    func fetchMovies(with searchTerm: String) async throws -> [APIMovie] {
        return try await apiController.fetchMovies(with: searchTerm)
    }
    
    func saveFavMovie(movie: APIMovie) {
        let newMovie = Movie(context: viewContext)
        newMovie.imdbID = movie.imdbID
        newMovie.posterURLString = movie.posterURL?.absoluteString
        newMovie.title = movie.title
        newMovie.year = movie.year
        PersistenceController.shared.saveContext()
    }
    
    func unfavoriteMovie(_ movie: Movie) {
        let context = viewContext
        context.delete(movie)
        PersistenceController.shared.saveContext()
    }
    
    func favoriteMovie(from movie: APIMovie) -> Movie? {
        let fetchRequest = Movie.fetchRequest()
        let predicate = NSPredicate(format: "imdbID CONTAINS[cd] %@", movie.imdbID)
        fetchRequest.predicate = predicate
        let result = try? PersistenceController.shared.viewContext.fetch(fetchRequest).first
        return result
    }
    
}
