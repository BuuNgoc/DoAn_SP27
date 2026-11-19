import React, { useState } from 'react';
import {
  Compass,
  Plus,
  Headphones,
  PlayCircle,
  ArrowRightCircle,
  Info,
  Trash2,
  Edit2,
  CheckCircle,
} from 'lucide-react';
import { VrScene, VrHotspot } from '../types';

interface VrHotspotCmsProps {
  scenes: VrScene[];
  onUpdateScenes: (scenes: VrScene[]) => void;
}

export const VrHotspotCms: React.FC<VrHotspotCmsProps> = ({
  scenes,
  onUpdateScenes,
}) => {
  const [activeSceneIndex, setActiveSceneIndex] = useState<number>(0);
  const [isModalOpen, setIsModalOpen] = useState<boolean>(false);
  const [editingHotspot, setEditingHotspot] = useState<VrHotspot | null>(null);

  // Form State
  const [title, setTitle] = useState('');
  const [yaw, setYaw] = useState(0);
  const [pitch, setPitch] = useState(0);
  const [type, setType] = useState<VrHotspot['type']>('INFO');
  const [description, setDescription] = useState('');
  const [audioUrl, setAudioUrl] = useState('');
  const [videoUrl, setVideoUrl] = useState('');
  const [nextSceneTitle, setNextSceneTitle] = useState('');

  const activeScene = scenes[activeSceneIndex];

  const handleOpenAdd = () => {
    setEditingHotspot(null);
    setTitle('');
    setYaw(0);
    setPitch(0);
    setType('INFO');
    setDescription('');
    setAudioUrl('');
    setVideoUrl('');
    setNextSceneTitle('');
    setIsModalOpen(true);
  };

  const handleOpenEdit = (hs: VrHotspot) => {
    setEditingHotspot(hs);
    setTitle(hs.title);
    setYaw(hs.yaw);
    setPitch(hs.pitch);
    setType(hs.type);
    setDescription(hs.description);
    setAudioUrl(hs.audioUrl);
    setVideoUrl(hs.videoUrl);
    setNextSceneTitle(hs.nextSceneTitle);
    setIsModalOpen(true);
  };

  const handleSaveHotspot = (e: React.FormEvent) => {
    e.preventDefault();
    if (!title) return;

    let updatedHotspots: VrHotspot[];
    if (editingHotspot) {
      updatedHotspots = activeScene.hotspots.map((h) =>
        h.id === editingHotspot.id
          ? {
              ...h,
              title,
              yaw,
              pitch,
              type,
              description,
              audioUrl,
              videoUrl,
              nextSceneTitle,
            }
          : h,
      );
    } else {
      const newHs: VrHotspot = {
        id: `hs_${Date.now()}`,
        title,
        yaw,
        pitch,
        type,
        description,
        audioUrl,
        videoUrl,
        nextSceneTitle,
      };
      updatedHotspots = [...activeScene.hotspots, newHs];
    }

    const updatedScenes = scenes.map((s, idx) =>
      idx === activeSceneIndex ? { ...s, hotspots: updatedHotspots } : s,
    );
    onUpdateScenes(updatedScenes);
    setIsModalOpen(false);
  };

  const handleDeleteHotspot = (id: string) => {
    const updatedHotspots = activeScene.hotspots.filter((h) => h.id !== id);
    const updatedScenes = scenes.map((s, idx) =>
      idx === activeSceneIndex ? { ...s, hotspots: updatedHotspots } : s,
    );
    onUpdateScenes(updatedScenes);
  };

  const getHotspotIcon = (t: VrHotspot['type']) => {
    switch (t) {
      case 'AUDIO':
        return <Headphones className="w-4 h-4 text-[#0D9488]" />;
      case 'VIDEO':
        return <PlayCircle className="w-4 h-4 text-[#DC2626]" />;
      case 'SCENE_TRANSITION':
        return <ArrowRightCircle className="w-4 h-4 text-[#2563EB]" />;
      default:
        return <Info className="w-4 h-4 text-[#173F35]" />;
    }
  };

  return (
    <div className="bg-white p-6 rounded-xl border border-[#E2E8F0] shadow-sm space-y-6">
      {/* ── Header ───────────────────────────────────────────────────────── */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h3 className="text-lg font-extrabold text-[#0F172A] tracking-tight">
            Quản Trị VR360 & Trình Biên Tập Hotspot Tương Tác (FE-18, Epic 4)
          </h3>
          <p className="text-xs text-[#64748B] mt-0.5">
            Cấu hình tọa độ góc quay (Yaw/Pitch), gắn Audio Thuyết Minh đa ngữ, Video giới thiệu & Tour tuyến liên thông
          </p>
        </div>
      </div>

      {/* ── Scene Selector Tabs ───────────────────────────────────────────── */}
      <div className="flex items-center space-x-2 border-b border-[#E2E8F0] pb-3 overflow-x-auto">
        {scenes.map((scene, idx) => (
          <button
            key={scene.id}
            onClick={() => setActiveSceneIndex(idx)}
            className={`px-4 py-2 rounded-lg text-xs font-bold transition-all whitespace-nowrap ${
              idx === activeSceneIndex
                ? 'bg-[#173F35] text-white shadow-sm'
                : 'bg-[#F8FAFC] text-[#64748B] hover:bg-[#F1F5F9] hover:text-[#0F172A]'
            }`}
          >
            {scene.title}
          </button>
        ))}
      </div>

      {/* ── Scene Workspace ───────────────────────────────────────────────── */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 bg-[#F8FAFC] p-5 rounded-xl border border-[#E2E8F0]">
        {/* Left: 360 Visual Card */}
        <div className="lg:col-span-5 space-y-3">
          <div className="h-56 bg-[#0F172A] rounded-xl overflow-hidden relative flex items-center justify-center border border-[#334155] shadow-inner">
            <Compass className="w-16 h-16 text-white/20 animate-spin-slow" />
            <div className="absolute top-3 right-3 bg-[#16A34A] text-white text-[10px] font-extrabold px-2 py-0.5 rounded flex items-center space-x-1 shadow">
              <CheckCircle className="w-3 h-3" />
              <span>WebXR Ready</span>
            </div>
            <div className="absolute bottom-3 left-3 bg-black/70 backdrop-blur-sm text-white text-xs px-2.5 py-1 rounded-md font-mono">
              {activeScene.resolution} • {activeScene.fileSize}
            </div>
          </div>
          <div>
            <h4 className="font-extrabold text-sm text-[#0F172A]">{activeScene.title}</h4>
            <p className="text-xs text-[#64748B]">
              Phân vùng: {activeScene.zone} • {activeScene.hotspots.length} điểm tương tác Hotspot đã kích hoạt
            </p>
          </div>
        </div>

        {/* Right: Hotspots List */}
        <div className="lg:col-span-7 space-y-3">
          <div className="flex items-center justify-between pb-2 border-b border-[#E2E8F0]">
            <h4 className="text-sm font-extrabold text-[#0F172A]">
              Danh Sách Hotspot Tương Tác ({activeScene.hotspots.length})
            </h4>
            <button
              onClick={handleOpenAdd}
              className="px-3 py-1.5 bg-[#173F35] hover:bg-[#244C40] text-white rounded-lg text-xs font-bold transition-all shadow-sm flex items-center space-x-1"
            >
              <Plus className="w-3.5 h-3.5" />
              <span>Thêm Hotspot Mới</span>
            </button>
          </div>

          <div className="space-y-2.5 max-h-[380px] overflow-y-auto pr-1">
            {activeScene.hotspots.map((hs) => (
              <div
                key={hs.id}
                className="bg-white p-3.5 rounded-xl border border-[#E2E8F0] shadow-sm flex items-start justify-between hover:border-[#CBD5E1] transition-all"
              >
                <div className="flex items-start space-x-3">
                  <div className="p-2 rounded-lg bg-[#F1F5F9] mt-0.5">
                    {getHotspotIcon(hs.type)}
                  </div>
                  <div>
                    <div className="text-sm font-bold text-[#0F172A]">{hs.title}</div>
                    <div className="text-xs text-[#64748B] mt-0.5 leading-relaxed">
                      {hs.description}
                    </div>
                    <div className="mt-1 flex items-center space-x-2 text-[11px] font-mono text-[#94A3B8]">
                      <span>Yaw: {hs.yaw}°</span>
                      <span>•</span>
                      <span>Pitch: {hs.pitch}°</span>
                      <span>•</span>
                      <span className="font-bold text-[#173F35]">{hs.type}</span>
                      {hs.nextSceneTitle && (
                        <span className="text-[#2563EB]">→ {hs.nextSceneTitle}</span>
                      )}
                    </div>
                  </div>
                </div>

                <div className="flex items-center space-x-1 shrink-0 ml-3">
                  <button
                    onClick={() => handleOpenEdit(hs)}
                    className="p-1 text-[#173F35] hover:bg-[#EBF2EF] rounded"
                  >
                    <Edit2 className="w-4 h-4" />
                  </button>
                  <button
                    onClick={() => handleDeleteHotspot(hs.id)}
                    className="p-1 text-[#DC2626] hover:bg-[#FEE2E2] rounded"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* ── Modal Add / Edit Hotspot ─────────────────────────────────────── */}
      {isModalOpen && (
        <div className="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl w-full max-w-lg p-6 shadow-2xl">
            <h4 className="font-extrabold text-[#0F172A] text-base mb-4">
              {editingHotspot ? 'Chỉnh Sửa Hotspot Tương Tác' : 'Thêm Hotspot Mới Trên Ảnh 360'}
            </h4>

            <form onSubmit={handleSaveHotspot} className="space-y-3.5">
              <div>
                <label className="block text-xs font-bold text-[#475569] mb-1">
                  Tiêu Đề Hotspot *
                </label>
                <input
                  type="text"
                  required
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  className="w-full px-3 py-2 border border-[#E2E8F0] rounded-lg text-sm outline-none focus:ring-2 focus:ring-[#173F35]"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-bold text-[#475569] mb-1">
                    Góc Ngang Yaw (-180° đến 180°)
                  </label>
                  <input
                    type="number"
                    step="0.5"
                    value={yaw}
                    onChange={(e) => setYaw(parseFloat(e.target.value))}
                    className="w-full px-3 py-2 border border-[#E2E8F0] rounded-lg text-sm font-mono outline-none"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-[#475569] mb-1">
                    Góc Đứng Pitch (-90° đến 90°)
                  </label>
                  <input
                    type="number"
                    step="0.5"
                    value={pitch}
                    onChange={(e) => setPitch(parseFloat(e.target.value))}
                    className="w-full px-3 py-2 border border-[#E2E8F0] rounded-lg text-sm font-mono outline-none"
                  />
                </div>
              </div>

              <div>
                <label className="block text-xs font-bold text-[#475569] mb-1">Loại Hotspot</label>
                <select
                  value={type}
                  onChange={(e) => setType(e.target.value as any)}
                  className="w-full px-3 py-2 border border-[#E2E8F0] rounded-lg text-sm outline-none font-semibold"
                >
                  <option value="INFO">Thông Tin Di Sản (Text & Popup)</option>
                  <option value="AUDIO">Thuyết Minh Audio Guide</option>
                  <option value="VIDEO">Video Clip Giới Thiệu</option>
                  <option value="SCENE_TRANSITION">Chuyển Cảnh VR360 Tiếp Theo (Tour Tuyến)</option>
                </select>
              </div>

              <div>
                <label className="block text-xs font-bold text-[#475569] mb-1">Nội Dung Chi Tiết</label>
                <textarea
                  rows={2}
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  className="w-full px-3 py-2 border border-[#E2E8F0] rounded-lg text-sm outline-none"
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-[#475569] mb-1">URL Audio Thuyết Minh</label>
                <input
                  type="text"
                  value={audioUrl}
                  onChange={(e) => setAudioUrl(e.target.value)}
                  className="w-full px-3 py-2 border border-[#E2E8F0] rounded-lg text-sm outline-none"
                />
              </div>

              {type === 'SCENE_TRANSITION' && (
                <div>
                  <label className="block text-xs font-bold text-[#475569] mb-1">Tên Cảnh Kế Tiếp</label>
                  <input
                    type="text"
                    value={nextSceneTitle}
                    onChange={(e) => setNextSceneTitle(e.target.value)}
                    className="w-full px-3 py-2 border border-[#E2E8F0] rounded-lg text-sm outline-none"
                  />
                </div>
              )}

              <div className="pt-3 border-t border-[#E2E8F0] flex justify-end space-x-2">
                <button
                  type="button"
                  onClick={() => setIsModalOpen(false)}
                  className="px-4 py-2 border border-[#E2E8F0] rounded-lg text-xs font-bold text-[#64748B]"
                >
                  Hủy Bỏ
                </button>
                <button
                  type="submit"
                  className="px-4 py-2 bg-[#173F35] text-white rounded-lg text-xs font-bold hover:bg-[#244C40]"
                >
                  Lưu Hotspot
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
