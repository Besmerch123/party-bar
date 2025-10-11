export interface ElasticDocument {
  id: string;

  [key: string]: unknown;
}

export interface ElasticSearchResults<TData> {
  items: TData[];
  total: number;
  page: number;
  pageSize: number;
  totalPages: number;
  hasNextPage: boolean;
  hasPreviousPage: boolean;
}
