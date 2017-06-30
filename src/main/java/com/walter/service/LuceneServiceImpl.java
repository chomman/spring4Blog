package com.walter.service;

import static com.walter.config.lambda.LambdaUtilForException.reThrowsConsumer;
import static com.walter.config.lambda.LambdaUtilForException.reThrowsFunction;

import com.walter.config.CustomStringUtils;
import com.walter.model.LuceneIndexVO;
import lombok.extern.slf4j.Slf4j;
import org.apache.lucene.analysis.Analyzer;
import org.apache.lucene.analysis.ko.KoreanAnalyzer;
import org.apache.lucene.document.Document;
import org.apache.lucene.document.Field;
import org.apache.lucene.document.FieldType;
import org.apache.lucene.index.*;
import org.apache.lucene.queryparser.classic.ParseException;
import org.apache.lucene.queryparser.classic.QueryParser;
import org.apache.lucene.search.*;
import org.apache.lucene.store.FSDirectory;
import org.springframework.stereotype.Service;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Stream;

/**
 * Created by yhwang131 on 2017-06-29.
 */
@Slf4j
@Service
public class LuceneServiceImpl implements LuceneService {
	private static final String LUCENE_INDEX_DIR = System.getProperty("user.home") + "/.lucene/data";
	private static final String FIELD = "SEARCH_ALL";
	private static final int DEFAULT_LIMIT_COUNT = 10000;

	@Override
	public void createIndex(List<? extends LuceneIndexVO> list) throws IOException {
		if (list.size() > 0) {
			File file = new File(LUCENE_INDEX_DIR, list.get(0).getClass().getSimpleName());
			FSDirectory fsDirectory = FSDirectory.open(file.toPath());

			Analyzer analyzer = new KoreanAnalyzer();
			IndexWriterConfig indexWriterConfig = new IndexWriterConfig(analyzer);
			indexWriterConfig.setOpenMode(IndexWriterConfig.OpenMode.CREATE);

			IndexWriter indexWriter = new IndexWriter(fsDirectory, indexWriterConfig);

			FieldType fieldType = new FieldType();
			fieldType.setIndexOptions(IndexOptions.DOCS_AND_FREQS);
			fieldType.setStored(true);
			fieldType.setTokenized(true);
			fieldType.freeze();

			indexWriter.deleteAll();
			list.stream().filter(i -> CustomStringUtils.isNotEmpty(i.getSeq())).forEach(reThrowsConsumer(i -> {
				Document document = new Document();
				document.add(new Field("SEQ", i.getSeq(), fieldType));
				document.add(new Field("TITLE", i.getTitle(), fieldType));
				document.add(new Field("CONTENT", i.getContent(), fieldType));

				document.add(new Field(FIELD, CustomStringUtils.stripToEmpty(i.getTitle()), fieldType));
				document.add(new Field(FIELD, CustomStringUtils.stripToEmpty(i.getContent()), fieldType));
				indexWriter.addDocument(document);
			}));

			indexWriter.commit();
			indexWriter.close();
			analyzer.close();
			fsDirectory.close();
		}
	}

	@Override
	public List<LuceneIndexVO> searchDataList(Class<? extends LuceneIndexVO> itemType, String searchText) throws IOException, ParseException {
		File file = new File(LUCENE_INDEX_DIR, itemType.getClass().getSimpleName());
		IndexReader indexReader = DirectoryReader.open(FSDirectory.open(file.toPath()));
		IndexSearcher indexSearcher = new IndexSearcher(indexReader);
		Analyzer analyzer = new KoreanAnalyzer();

		QueryParser parser = new QueryParser(FIELD, analyzer);

		List<LuceneIndexVO> result = new ArrayList<>();
		if (CustomStringUtils.isNotEmpty(searchText)) {
			Query query = parser.parse(CustomStringUtils.stripToEmpty(searchText));
			log.info("### Searching for : {}", query.toString());
			searchAndBinding(indexSearcher, query, itemType, result);
		}
		return result;
	}

	private void searchAndBinding(IndexSearcher indexSearcher, Query query,
	                            Class<? extends LuceneIndexVO> itemType, List<LuceneIndexVO> result) throws IOException {
		SortField sortField = new SortField("SEQ", SortField.Type.STRING, true);
		Sort sort = new Sort(sortField);

		TopDocs results = indexSearcher.search(query, DEFAULT_LIMIT_COUNT, sort);
		//ScoreDoc[] hits = results.scoreDocs;

		Stream<ScoreDoc> scoreDocStream = Arrays.asList(results.scoreDocs).stream();
		scoreDocStream.map(reThrowsFunction(d -> indexSearcher.doc(d.doc))).forEach(reThrowsConsumer(d -> {
			LuceneIndexVO idx = itemType.newInstance();
			idx.setSeq(d.get("SEQ"));
			idx.setTitle(d.get("TITLE"));
			idx.setContent(d.get("CONTENT"));
			result.add(idx);
		}));
	}
}
