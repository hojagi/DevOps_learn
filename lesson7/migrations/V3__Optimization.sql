CREATE INDEX idx_orders_client_book ON orders(client_id, book_id);
CREATE INDEX idx_clients_id ON clients(id);
CREATE INDEX idx_books_id ON books(id);