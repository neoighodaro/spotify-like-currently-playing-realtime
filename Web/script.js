$(function() {
  var playerTrack = $('#player-track'),
    bgArtwork = $('#bg-artwork'),
    bgArtworkUrl,
    albumName = $('#album-name'),
    trackName = $('#track-name'),
    albumArt = $('#album-art'),
    seekBar = $('#seek-bar'),
    trackTime = $('#track-time'),
    playPauseButton = $('#play-pause-button'),
    i = playPauseButton.find('i'),
    tProgress = $('#current-time'),
    tTime = $('#track-length'),
    curMinutes,
    curSeconds,
    durMinutes,
    durSeconds,
    playProgress,
    bTime,
    nTime = 0,
    buffInterval = null,
    tFlag = false,
    albums = ['JugHead'],
    trackNames = ['Polly'],
    albumArtworks = ['_1'],
    trackUrl = ['/jingle.mp3'],
    currIndex = -1;

  function playPause() {
    setTimeout(function() {
      if (audio.paused) {
        playerTrack.addClass('active');
        albumArt.addClass('active');
        checkBuffering();
        i.attr('class', 'fas fa-pause');
        audio.play();
      } else {
        playerTrack.removeClass('active');
        albumArt.removeClass('active');
        clearInterval(buffInterval);
        albumArt.removeClass('buffering');
        i.attr('class', 'fas fa-play');
        audio.pause();
      }
    }, 300);
  }

  function updateCurrTime() {
    nTime = new Date();
    nTime = nTime.getTime();

    if (!tFlag) {
      tFlag = true;
      trackTime.addClass('active');
    }

    curMinutes = Math.floor(audio.currentTime / 60);
    curSeconds = Math.floor(audio.currentTime - curMinutes * 60);

    durMinutes = Math.floor(audio.duration / 60);
    durSeconds = Math.floor(audio.duration - durMinutes * 60);

    playProgress = (audio.currentTime / audio.duration) * 100;

    if (curMinutes < 10) curMinutes = '0' + curMinutes;
    if (curSeconds < 10) curSeconds = '0' + curSeconds;

    if (durMinutes < 10) durMinutes = '0' + durMinutes;
    if (durSeconds < 10) durSeconds = '0' + durSeconds;

    if (isNaN(curMinutes) || isNaN(curSeconds)) tProgress.text('00:00');
    else tProgress.text(curMinutes + ':' + curSeconds);

    if (isNaN(durMinutes) || isNaN(durSeconds)) tTime.text('00:00');
    else tTime.text(durMinutes + ':' + durSeconds);

    if (isNaN(curMinutes) || isNaN(curSeconds) || isNaN(durMinutes) || isNaN(durSeconds))
      trackTime.removeClass('active');
    else trackTime.addClass('active');

    seekBar.width(playProgress + '%');

    if (playProgress == 100) {
      i.attr('class', 'fa fa-play');
      seekBar.width(0);
      tProgress.text('00:00');
      albumArt.removeClass('buffering').removeClass('active');
      clearInterval(buffInterval);
    }
  }

  function checkBuffering() {
    clearInterval(buffInterval);
    buffInterval = setInterval(function() {
      if (nTime == 0 || bTime - nTime > 1000) albumArt.addClass('buffering');
      else albumArt.removeClass('buffering');

      bTime = new Date();
      bTime = bTime.getTime();
    }, 100);
  }

  function selectTrack(flag) {
    if (flag == 0 || flag == 1) ++currIndex;
    else --currIndex;

    if (currIndex > -1 && currIndex < albumArtworks.length) {
      if (flag == 0) i.attr('class', 'fa fa-play');
      else {
        albumArt.removeClass('buffering');
        i.attr('class', 'fa fa-pause');
      }

      seekBar.width(0);
      trackTime.removeClass('active');
      tProgress.text('00:00');
      tTime.text('00:00');

      currAlbum = albums[currIndex];
      currTrackName = trackNames[currIndex];
      currArtwork = albumArtworks[currIndex];

      audio.src = trackUrl[currIndex];

      nTime = 0;
      bTime = new Date();
      bTime = bTime.getTime();

      if (flag != 0) {
        audio.play();
        playerTrack.addClass('active');
        albumArt.addClass('active');

        clearInterval(buffInterval);
        checkBuffering();
      }

      albumName.text(currAlbum);
      trackName.text(currTrackName);
      albumArt.find('img.active').removeClass('active');
      $('#' + currArtwork).addClass('active');

      bgArtworkUrl = $('#' + currArtwork).attr('src');

      bgArtwork.css({
        'background-image': 'url(' + bgArtworkUrl + ')'
      });
    } else {
      if (flag == 0 || flag == 1) --currIndex;
      else ++currIndex;
    }
  }

  function initPlayer() {
    audio = new Audio();
    audio.loop = false;
    selectTrack(0);

    playPauseButton.on('click', playPause);
    $(audio).on('timeupdate', updateCurrTime);
  }

  initPlayer();
});
