---
title: "100 best movies"
# collection: talks
# type: "Talk"
permalink: /100-movies/
date: 2024-11-03
# tags:
  # - talk
---

The order is randomized on each page load. There is no order! 

<head>
    <style>
        table {
            width: 100%;
            border-collapse: collapse;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 8px;
        }
        th {
            cursor: pointer;
        }
        .asc::after {
            content: " ▲";
        }
        .desc::after {
            content: " ▼";
        }
    </style>
</head>


<table id="moviesTable">
    <thead>
        <tr>
            <th onclick="sortTable(0)">Title</th>
            <th onclick="sortTable(1)">Year</th>
            <th>Description</th>
        </tr>
    </thead>
    <tbody id="moviesBody">
        <!-- Movies will be populated here by JavaScript -->
    </tbody>
</table>

<script>
    const movies = [
        { title: "WALL·E", year: 2008, link: "https://www.themoviedb.org/movie/10681-wall-e", description: "" },
        { title: "American Fiction", year: 2023, link: "https://www.themoviedb.org/movie/1056360-american-fiction", description: "" },
        { title: "The Big Lebowski", year: 1998, link: "https://www.themoviedb.org/movie/115-the-big-lebowski", description: "" },
        { title: "Bo Burnham: Inside", year: 2021, link: "https://www.themoviedb.org/movie/823754-bo-burnham-inside", description: "" },
        { title: "Bottoms", year: 2023, link: "https://www.themoviedb.org/movie/814776-bottoms", description: "" },
        { title: "The Dark Knight", year: 2008, link: "https://www.themoviedb.org/movie/155-the-dark-knight", description: "" },
        { title: "Demon Slayer: Mugen Train", year: 2020, link: "https://www.themoviedb.org/movie/635302", description: "" },
        { title: "Eternal Sunshine of the Spotless Mind", year: 2004, link: "https://www.themoviedb.org/movie/38-eternal-sunshine-of-the-spotless-mind", description: "" },
        { title: "Everything Everywhere All at Once", year: 2022, link: "https://www.themoviedb.org/movie/545611-everything-everywhere-all-at-once", description: "" },
        { title: "Fresh", year: 2022, link: "https://www.themoviedb.org/movie/787752-fresh", description: "asdas as" },
        { title: "Heat", year: 1995, link: "https://www.themoviedb.org/movie/949-heat", description: "" },
        { title: "Heathers", year: 1989, link: "https://www.themoviedb.org/movie/2640-heathers", description: "" },
        { title: "The Holdovers", year: 2023, link: "https://www.themoviedb.org/movie/840430-the-holdovers", description: "" },
        { title: "Ikiru", year: 1952, link: "https://www.themoviedb.org/movie/3782", description: "" },
        { title: "John Wick", year: 2014, link: "https://www.themoviedb.org/movie/245891-john-wick", description: "" },
        { title: "Life is Beautiful", year: 1997, link: "https://www.themoviedb.org/movie/637-la-vita-e-bella", description: "" },
        { title: "Monkey Man", year: 2024, link: "https://www.themoviedb.org/movie/560016-monkey-man", description: "" },
        { title: "Nightcrawler", year: 2014, link: "https://www.themoviedb.org/movie/242582-nightcrawler", description: "" },
        { title: "Nobody", year: 2021, link: "https://www.themoviedb.org/movie/615457-nobody", description: "" },
        { title: "The Northman", year: 2022, link: "https://www.themoviedb.org/movie/639933-the-northman", description: "" },
        { title: "Office Space", year: 1999, link: "https://www.themoviedb.org/movie/1542-office-space", description: "" },
        { title: "Paprika", year: 2007, link: "https://www.themoviedb.org/movie/4977", description: "" },
        { title: "Parasite", year: 2019, link: "https://www.themoviedb.org/movie/496243", description: "" },
        { title: "Perfect Days", year: 2023, link: "https://www.themoviedb.org/movie/976893-perfect-days", description: "" },
        { title: "The Silence of the Lambs", year: 1991, link: "https://www.themoviedb.org/movie/274-the-silence-of-the-lambs", description: "" },
        { title: "Spider-Man: Into the Spider-Verse", year: 2018, link: "https://www.themoviedb.org/movie/324857-spider-man-into-the-spider-verse", description: "" },
        { title: "The Whale", year: 2022, link: "https://www.themoviedb.org/movie/785084-the-whale", description: "" },
        { title: "What's Eating Gilbert Grape", year: 1993, link: "https://www.themoviedb.org/movie/1587-what-s-eating-gilbert-grape", description: "" },
        { title: "The Woman King", year: 2022, link: "https://www.themoviedb.org/movie/724495-the-woman-king", description: "" },
        { title: "A Woman Under the Influence", year: 1974, link: "https://www.themoviedb.org/movie/29845-a-woman-under-the-influence", description: "" },
        { title: "Yes Man", year: 2008, link: "https://www.themoviedb.org/movie/10201-yes-man", description: "" },
        { title: "The Thing", year: , link: "", description: "" },
        { title: "To Catch a Killer", year: , link: "", description: "" },
        // { title: "", year: , link: "", description: "" },
        // { title: "", year: , link: "", description: "" },
        // { title: "", year: , link: "", description: "" },
        // { title: "", year: , link: "", description: "" },
        // { title: "", year: , link: "", description: "" },
        // { title: "", year: , link: "", description: "" },
        // { title: "", year: , link: "", description: "" },
        // { title: "", year: , link: "", description: "" },
        // { title: "", year: , link: "", description: "" },
        // { title: "", year: , link: "", description: "" },
        // { title: "", year: , link: "", description: "" },
        // { title: "", year: , link: "", description: "" },
        // { title: "", year: , link: "", description: "" },
        // { title: "", year: , link: "", description: "" },
        // { title: "", year: , link: "", description: "" },
        // { title: "", year: , link: "", description: "" },
        // { title: "", year: , link: "", description: "" },
        // { title: "", year: , link: "", description: "" },
        // { title: "", year: , link: "", description: "" },

        // APPEND MOVIES HERE
    ];

    let sortOrder = [true, true]; // true for ascending, false for descending

    function shuffle(array) {
        for (let i = array.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [array[i], array[j]] = [array[j], array[i]];
        }
    }

    function populateTable() {
        shuffle(movies);
        const tbody = document.getElementById('moviesBody');
        tbody.innerHTML = '';
        movies.forEach(movie => {
            const row = document.createElement('tr');
            const titleCell = document.createElement('td');
            const yearCell = document.createElement('td');
            const descCell = document.createElement('td');
            titleCell.innerHTML = `<a href="${movie.link}">${movie.title}</a>`;
            yearCell.textContent = movie.year;
            descCell.textContent = movie.description;
            row.appendChild(titleCell);
            row.appendChild(yearCell);
            row.appendChild(descCell);
            tbody.appendChild(row);
        });
    }

    function sortTable(columnIndex) {
        const table = document.getElementById("moviesTable");
        const rows = Array.from(table.rows).slice(1);
        const isAscending = sortOrder[columnIndex];
        const sortedRows = rows.sort((a, b) => {
            const cellA = a.cells[columnIndex].innerText;
            const cellB = b.cells[columnIndex].innerText;
            return isAscending ? cellA.localeCompare(cellB) : cellB.localeCompare(cellA);
        });
        sortOrder[columnIndex] = !isAscending;
        const tbody = table.tBodies[0];
        tbody.innerHTML = '';
        sortedRows.forEach(row => tbody.appendChild(row));
        updateSortIcons(columnIndex, isAscending);
    }

    function updateSortIcons(columnIndex, isAscending) {
        const headers = document.querySelectorAll('th');
        headers.forEach((header, index) => {
            header.classList.remove('asc', 'desc');
            if (index === columnIndex) {
                header.classList.add(isAscending ? 'asc' : 'desc');
            }
        });
    }

    window.onload = populateTable;
</script>

