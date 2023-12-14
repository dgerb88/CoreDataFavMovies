//
//  FavoritesViewController.swift
//  CoreDataFavoriteMovies
//
//  Created by Parker Rushton on 11/3/22.
//

import UIKit

class FavoritesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var backgroundView: UIView!
    
    private var datasource: UITableViewDiffableDataSource<Int, Movie>!
    private let movieController = MovieController.shared
    
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.delegate = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Search a movie title"
        sc.searchBar.delegate = self
        return sc
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        navigationItem.searchController = searchController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchFavorites()
    }
    
    func fetchFavorites() {
        if searchController.searchBar.text != "" {
            let fetchRequest = Movie.fetchRequest()
            let searchString = searchController.searchBar.text ?? ""
            let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchString)
            fetchRequest.predicate = predicate
            let results = try? PersistenceController.shared.viewContext.fetch(fetchRequest)
            applyNewSnapshot(from: results ?? [])
        } else {
            let fetchRequest = Movie.fetchRequest()
            let searchString = searchController.searchBar.text ?? ""
            let results = try? PersistenceController.shared.viewContext.fetch(fetchRequest)
            applyNewSnapshot(from: results ?? [])
        }
    }
}

private extension FavoritesViewController {
    
    func setUpTableView() {
        tableView.backgroundView = backgroundView
        setUpDataSource()
        tableView.register(UINib(nibName: "MovieTableViewCell", bundle: nil), forCellReuseIdentifier: MovieTableViewCell.reuseIdentifier)
    }
    
    //Here is the problem
    func setUpDataSource() {
        datasource = UITableViewDiffableDataSource<Int, Movie>(tableView: tableView) { tableView, indexPath, movie in
            let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.reuseIdentifier) as! MovieTableViewCell
            cell.updateWithCD(with: movie) {
                self.toggleFavorite(movie)
            }
            return cell
        }
    }
    
    func toggleFavorite(_ movie: Movie) {
        // TODO: Save movie to core data so it can become a favorite
        removeFavorite(movie)
    }
    
    func applyNewSnapshot(from movies: [Movie]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Movie>()
        snapshot.appendSections([0])
        snapshot.appendItems(movies)
        datasource?.apply(snapshot, animatingDifferences: true)
        tableView.backgroundView = movies.isEmpty ? backgroundView : nil
    }

    func removeFavorite(_ movie: Movie) {
        movieController.unfavoriteMovie(movie)
        var snapshot = datasource.snapshot()
        snapshot.deleteItems([movie])
        datasource?.apply(snapshot, animatingDifferences: true)
    }
    
    func reload(_ movie: Movie) {
        var snapshot = datasource.snapshot()
        snapshot.reloadItems([movie])
        datasource?.apply(snapshot, animatingDifferences: true)
    }
    
}

extension FavoritesViewController: UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, text.isEmpty {
            fetchFavorites()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        fetchFavorites()
    }
    
}

extension FavoritesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
