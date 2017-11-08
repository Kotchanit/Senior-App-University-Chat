import UIKit
import FirebaseDatabaseUI

class EditableTableViewDataSource: FUITableViewDataSource {
    
    /// Called to populate each cell in the UITableView.
    typealias PopulateCellBlock = (UITableView, IndexPath, DataSnapshot) -> UITableViewCell
    
    /// Called to commit an edit to the UITableView.
    typealias CommitEditBlock = (UITableView, UITableViewCellEditingStyle, IndexPath, DataSnapshot) -> Void
    
    private let commitEditBlock: CommitEditBlock?
    
    /// A wrapper around FUITableViewDataSource.init(query:view tableView:populateCell:), with the
    /// addition of a CommitEditBlock.
    public init(query: DatabaseQuery,
                populateCell: @escaping PopulateCellBlock,
                commitEdit: @escaping CommitEditBlock)
    {
        commitEditBlock = commitEdit
        super.init(collection: FUIArray.init(query: query), populateCell: populateCell)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCellEditingStyle,
                            forRowAt indexPath: IndexPath)
    {
        if (commitEditBlock != nil) {
            commitEditBlock!(tableView, editingStyle, indexPath, snapshot(at: indexPath.row))
        }
    }
    
}

extension UITableView {
    
    /// Creates a data source, binds it to the table view, and returns it. Note that this is the
    /// `EditableTableViewDataSource` equivalent of the
    /// `FUITableViewDataSource.bind(to:populateCell:)` method.
    ///
    /// - parameters:
    ///   - to:             The Firebase query to bind to.
    ///   - populateCell:   A closure that's called to populate each cell.
    ///   - commitEdit:     A closure that's called when the user commits some kind of edit. Maps to
    ///                     `tableView(:commit:forRowAt:)`.
    func bind(to query: DatabaseQuery,
              populateCell: @escaping EditableTableViewDataSource.PopulateCellBlock,
              commitEdit: @escaping EditableTableViewDataSource.CommitEditBlock)
        -> EditableTableViewDataSource
    {
        let dataSource = EditableTableViewDataSource(query: query,
                                                 populateCell: populateCell,
                                                 commitEdit: commitEdit)
        dataSource.bind(to: self)
        return dataSource
    }
    
}
